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
    case COACH_RELATIONSHIP_REQUESTED = 'coach_relationship.requested';
    case COACH_RELATIONSHIP_APPROVED = 'coach_relationship.approved';
    case COACH_RELATIONSHIP_REJECTED = 'coach_relationship.rejected';
    case COACH_RELATIONSHIP_CANCELLED = 'coach_relationship.cancelled';
    case COACH_RELATIONSHIP_ENDED = 'coach_relationship.ended';
    case BODY_MEASUREMENT_CREATED = 'body_measurement.created';
    case BODY_MEASUREMENT_UPDATED = 'body_measurement.updated';
    case BODY_MEASUREMENT_DELETED = 'body_measurement.deleted';
    case EXERCISE_CREATED = 'exercise.created';
    case EXERCISE_UPDATED = 'exercise.updated';
    case EXERCISE_DELETED = 'exercise.deleted';
    case WORKOUT_PROGRAM_CREATED = 'workout_program.created';
    case WORKOUT_PROGRAM_UPDATED = 'workout_program.updated';
    case WORKOUT_PROGRAM_DELETED = 'workout_program.deleted';
    case WORKOUT_ASSIGNMENT_CREATED = 'workout_assignment.created';
    case WORKOUT_ASSIGNMENT_ENDED = 'workout_assignment.ended';
    case WORKOUT_SESSION_CREATED = 'workout_session.created';
    case WORKOUT_SESSION_UPDATED = 'workout_session.updated';
    case WORKOUT_SESSION_DELETED = 'workout_session.deleted';
    case CARDIO_SESSION_CREATED = 'cardio_session.created';
    case CARDIO_SESSION_UPDATED = 'cardio_session.updated';
    case CARDIO_SESSION_DELETED = 'cardio_session.deleted';
    case ADMIN_USER_VIEWED = 'admin.user_viewed';
    case ADMIN_AUDIT_LOGS_VIEWED = 'admin.audit_logs_viewed';
}
