<?php

namespace App\Enums;

enum RoleName: string
{
    case SUPER_ADMIN = 'super_admin';
    case COACH = 'coach';
    case TRAINEE = 'trainee';
}
