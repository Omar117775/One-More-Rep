<?php

namespace App\Http\Controllers\Api\V1\Profile;

use App\Http\Controllers\Controller;
use App\Http\Requests\Profile\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use App\Models\CoachProfile;
use App\Models\TraineeProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $user = $request->user()->loadMissing(['roles', 'coachProfile', 'traineeProfile']);

        return (new UserResource($user))->response();
    }

    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validated();

        DB::transaction(function () use ($user, $data) {
            $accountFields = array_intersect_key($data, array_flip(['name', 'locale', 'timezone']));
            if ($accountFields !== []) {
                $user->update($accountFields);
            }

            if ($user->isTrainee()) {
                $traineeFields = array_intersect_key($data, array_flip([
                    'date_of_birth', 'sex', 'height_cm', 'initial_weight_kg',
                ]));

                if ($traineeFields !== []) {
                    TraineeProfile::firstOrCreate(['user_id' => $user->id])->update($traineeFields);
                }
            }

            if ($user->isCoach()) {
                $coachFields = array_intersect_key($data, array_flip(['display_name', 'bio']));

                if ($coachFields !== []) {
                    CoachProfile::firstOrCreate(['user_id' => $user->id])->update($coachFields);
                }
            }
        });

        $user = $user->fresh(['roles', 'coachProfile', 'traineeProfile']);

        return (new UserResource($user))->response();
    }
}
