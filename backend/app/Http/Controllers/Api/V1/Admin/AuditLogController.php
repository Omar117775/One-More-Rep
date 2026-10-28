<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use Illuminate\Http\JsonResponse;

class AuditLogController extends Controller
{
    public function index(): JsonResponse
    {
        $this->authorize('viewAny', AuditLog::class);

        $logs = AuditLog::query()
            ->with('actor:id,name,email')
            ->select(['id', 'actor_user_id', 'action', 'entity_type', 'entity_id', 'metadata', 'created_at'])
            ->orderByDesc('id')
            ->limit(100)
            ->get();

        return response()->json(['data' => $logs]);
    }
}
