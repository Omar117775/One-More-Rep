<?php

namespace App\Enums\Enums;

enum AuditAction: string
{
    case USER_REGISTERED = 'user.registered';
    case USER_CREATED = 'user.created';
    case USER_SUPER_ADMIN_CREATED = 'user.super_admin_created';
    case USER_ROLES_ASSIGNED = 'user.roles_assigned';
    case USER_STATUS_CHANGED = 'user.status_changed';
    case USER_PASSWORD_CHANGED = 'user.password_changed';
    case AUTH_PASSWORD_RESET = 'auth.password_reset';
    case COACH_RELATIONSHIP_CREATED = 'coach_relationship.created';
    case COACH_RELATIONSHIP_ENDED = 'coach_relationship.ended';
    case ADMIN_USER_VIEWED = 'admin.user_viewed';
    case ADMIN_AUDIT_LOGS_VIEWED = 'admin.audit_logs_viewed';
}
