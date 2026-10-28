<?php

namespace App\Services\Audit;

use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;

class AuditLogger
{
    public function log(?Model $actor, string $action, Model $entity, array $metadata = []): AuditLog
    {
        return AuditLog::create([
            'actor_user_id' => $actor instanceof User ? $actor->id : null,
            'action' => $action,
            'entity_type' => $entity->getMorphClass(),
            'entity_id' => $entity->getKey(),
            'metadata' => $this->redact($metadata),
            'created_at' => now(),
        ]);
    }

    private function redact(array $data): array
    {
        $sensitive = ['password', 'password_confirmation', 'token', 'access_token', 'authorization', 'cookie', 'secret', 'card', 'cvv', 'payment_reference'];
        $result = [];
        foreach ($data as $key => $value) {
            $lower = strtolower((string) $key);
            $isSensitive = false;
            foreach ($sensitive as $s) {
                if (str_contains($lower, $s)) {
                    $isSensitive = true;
                    break;
                }
            }
            if ($isSensitive) {
                $result[$key] = '[REDACTED]';

                continue;
            }
            if (is_array($value)) {
                $result[$key] = $this->redact($value);

                continue;
            }
            $result[$key] = $value;
        }

        return $result;
    }
}
