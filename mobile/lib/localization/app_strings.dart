import 'package:flutter/widgets.dart';

/// Centralized English/Arabic strings. A simple typed strings map on purpose:
/// Flutter's built-in delegates handle localization plumbing, this only holds copy.
class AppStrings {
  const AppStrings(
    this.localeName, {
    required this.splashCta,
    required this.splashMotto,
    required this.splashTagline,
    required this.signInTitle,
    required this.signInSubtitle,
    required this.emailLabel,
    required this.passwordLabel,
    required this.advancedSection,
    required this.apiUrlLabel,
    required this.apiUrlHint,
    required this.signInButton,
    required this.signingIn,
    required this.errInvalidEmail,
    required this.errPasswordRequired,
    required this.errWrongCredentials,
    required this.navHome,
    required this.navTrain,
    required this.navCardio,
    required this.navProgress,
    required this.navSettings,
    required this.greetingMorning,
    required this.greetingAfternoon,
    required this.greetingEvening,
    required this.greetingNight,
    required this.homeActiveProgram,
    required this.homeNoProgram,
    required this.homeNoProgramSub,
    required this.homeBeginSession,
    required this.homeViewProgram,
    required this.homeQuickActions,
    required this.homeQuickWorkout,
    required this.homeQuickCardio,
    required this.homeQuickProgress,
    required this.homeWorkoutsSummary,
    required this.homeCardioSummary,
    required this.homeBodySummary,
    required this.homeCompanionIdle,
    required this.homeCompanionTraining,
    required this.homeCompanionSuccess,
    required this.homeCompanionMilestone,
    required this.homeNoWorkouts30,
    required this.homeNoCardio30,
    required this.homeNoBody30,
    required this.trainTitle,
    required this.trainNoAssignments,
    required this.trainNoAssignmentsSub,
    required this.trainActive,
    required this.trainUpcoming,
    required this.trainEnded,
    required this.trainDays,
    required this.trainStarts,
    required this.trainEnds,
    required this.openProgram,
    required this.exercisesCount,
    required this.targetSetsShort,
    required this.targetRepsShort,
    required this.targetWeightShort,
    required this.restShort,
    required this.dayLabel,
    required this.startSession,
    required this.sessionHistory,
    required this.sessionNotes,
    required this.notesHint,
    required this.finishSession,
    required this.saveDraft,
    required this.deleteSession,
    required this.deleteSessionConfirm,
    required this.sessionsEmpty,
    required this.sessionsEmptySub,
    required this.sessionStartedAt,
    required this.sessionCompletedAt,
    required this.completedBadge,
    required this.pendingBadge,
    required this.noSetsSelected,
    required this.saveSessionFailed,
    required this.cardioTitle,
    required this.addCardio,
    required this.editCardio,
    required this.activityType,
    required this.activityRun,
    required this.activityWalk,
    required this.activityCycling,
    required this.activitySwimming,
    required this.activityRowing,
    required this.activityOther,
    required this.durationMinutes,
    required this.distanceKm,
    required this.avgHeartRate,
    required this.performedAt,
    required this.deleteEntry,
    required this.deleteEntryConfirm,
    required this.cardioEmpty,
    required this.cardioEmptySub,
    required this.progressTitle,
    required this.range7,
    required this.range30,
    required this.range90,
    required this.range365,
    required this.chartBodyWeight,
    required this.chartWorkoutVolume,
    required this.chartCardioDuration,
    required this.addMeasurement,
    required this.editMeasurement,
    required this.weightKg,
    required this.bodyFatPercentage,
    required this.waistCm,
    required this.chestCm,
    required this.armCm,
    required this.measuredOn,
    required this.measurementsHeader,
    required this.measurementsEmpty,
    required this.measurementsEmptySub,
    required this.deleteMeasurement,
    required this.deleteMeasurementConfirm,
    required this.settingsTitle,
    required this.languageSection,
    required this.languageEnglish,
    required this.languageArabic,
    required this.apiSection,
    required this.apiBaseUrl,
    required this.saveApiUrl,
    required this.savedNote,
    required this.signOut,
    required this.signOutConfirm,
    required this.aboutSection,
    required this.appVersionLabel,
    required this.profileNote,
    required this.ok,
    required this.cancel,
    required this.delete,
    required this.retry,
    required this.requiredField,
    required this.invalidNumber,
    required this.seeAll,
    required this.noDataForPeriod,
    required this.errorGeneric,
    required this.loadingLabel,
    required this.today,
    required this.last30Days,
    required this.p5LoadingProfile,
  });

  final String localeName;

  // Splash
  final String splashCta;
  final String splashMotto;
  final String splashTagline;

  // Sign-in
  final String signInTitle;
  final String signInSubtitle;
  final String emailLabel;
  final String passwordLabel;
  final String advancedSection;
  final String apiUrlLabel;
  final String apiUrlHint;
  final String signInButton;
  final String signingIn;
  final String errInvalidEmail;
  final String errPasswordRequired;
  final String errWrongCredentials;

  // Shell
  final String navHome;
  final String navTrain;
  final String navCardio;
  final String navProgress;
  final String navSettings;

  // Home
  final String greetingMorning;
  final String greetingAfternoon;
  final String greetingEvening;
  final String greetingNight;
  final String homeActiveProgram;
  final String homeNoProgram;
  final String homeNoProgramSub;
  final String homeBeginSession;
  final String homeViewProgram;
  final String homeQuickActions;
  final String homeQuickWorkout;
  final String homeQuickCardio;
  final String homeQuickProgress;
  final String homeWorkoutsSummary;
  final String homeCardioSummary;
  final String homeBodySummary;
  final String homeCompanionIdle;
  final String homeCompanionTraining;
  final String homeCompanionSuccess;
  final String homeCompanionMilestone;
  final String homeNoWorkouts30;
  final String homeNoCardio30;
  final String homeNoBody30;

  // Train
  final String trainTitle;
  final String trainNoAssignments;
  final String trainNoAssignmentsSub;
  final String trainActive;
  final String trainUpcoming;
  final String trainEnded;
  final String trainDays;
  final String trainStarts;
  final String trainEnds;
  final String openProgram;
  final String exercisesCount;
  final String targetSetsShort;
  final String targetRepsShort;
  final String targetWeightShort;
  final String restShort;
  final String dayLabel;
  final String startSession;
  final String sessionHistory;
  final String sessionNotes;
  final String notesHint;
  final String finishSession;
  final String saveDraft;
  final String deleteSession;
  final String deleteSessionConfirm;
  final String sessionsEmpty;
  final String sessionsEmptySub;
  final String sessionStartedAt;
  final String sessionCompletedAt;
  final String completedBadge;
  final String pendingBadge;
  final String noSetsSelected;
  final String saveSessionFailed;

  // Cardio
  final String cardioTitle;
  final String addCardio;
  final String editCardio;
  final String activityType;
  final String activityRun;
  final String activityWalk;
  final String activityCycling;
  final String activitySwimming;
  final String activityRowing;
  final String activityOther;
  final String durationMinutes;
  final String distanceKm;
  final String avgHeartRate;
  final String performedAt;
  final String deleteEntry;
  final String deleteEntryConfirm;
  final String cardioEmpty;
  final String cardioEmptySub;

  // Progress
  final String progressTitle;
  final String range7;
  final String range30;
  final String range90;
  final String range365;
  final String chartBodyWeight;
  final String chartWorkoutVolume;
  final String chartCardioDuration;
  final String addMeasurement;
  final String editMeasurement;
  final String weightKg;
  final String bodyFatPercentage;
  final String waistCm;
  final String chestCm;
  final String armCm;
  final String measuredOn;
  final String measurementsHeader;
  final String measurementsEmpty;
  final String measurementsEmptySub;
  final String deleteMeasurement;
  final String deleteMeasurementConfirm;

  // Settings
  final String settingsTitle;
  final String languageSection;
  final String languageEnglish;
  final String languageArabic;
  final String apiSection;
  final String apiBaseUrl;
  final String saveApiUrl;
  final String savedNote;
  final String signOut;
  final String signOutConfirm;
  final String aboutSection;
  final String appVersionLabel;
  final String profileNote;

  // Common
  final String ok;
  final String cancel;
  final String delete;
  final String retry;
  final String requiredField;
  final String invalidNumber;
  final String seeAll;
  final String noDataForPeriod;
  final String errorGeneric;
  final String loadingLabel;
  final String today;
  final String last30Days;
  final String p5LoadingProfile;

  static const AppStrings english = _en;
  static const AppStrings arabic = _ar;
  static const AppStrings fallback = _en;

  /// Looks up the strings installed by [AppStringsScope]; falls back to English.
  static AppStrings of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppStringsScope>();
    return scope?.strings ?? fallback;
  }
}

class AppStringsScope extends InheritedWidget {
  const AppStringsScope({required this.strings, required super.child, super.key});

  final AppStrings strings;

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) =>
      oldWidget.strings != strings;
}

const _en = AppStrings(
  'en',
  splashCta: 'ENTER THE ARENA',
  splashMotto: 'STRENGTH  •  DISCIPLINE  •  PROGRESS',
  splashTagline: 'BUILT THROUGH DISCIPLINE',
  signInTitle: 'WELCOME BACK',
  signInSubtitle: 'Sign in to continue your training.',
  emailLabel: 'EMAIL',
  passwordLabel: 'PASSWORD',
  advancedSection: 'Advanced',
  apiUrlLabel: 'API BASE URL',
  apiUrlHint: 'http://10.0.2.2:8000/api/v1',
  signInButton: 'SIGN IN',
  signingIn: 'Signing you in…',
  errInvalidEmail: 'Enter a valid email address.',
  errPasswordRequired: 'Enter your password.',
  errWrongCredentials: 'Sign-in failed. Check your credentials and API URL.',
  navHome: 'Home',
  navTrain: 'Train',
  navCardio: 'Cardio',
  navProgress: 'Progress',
  navSettings: 'Settings',
  greetingMorning: 'Good morning',
  greetingAfternoon: 'Good afternoon',
  greetingEvening: 'Good evening',
  greetingNight: 'Hitting it late',
  homeActiveProgram: 'ACTIVE PROGRAM',
  homeNoProgram: 'No active program yet',
  homeNoProgramSub: 'Your coach will assign one soon. Time to sharpen focus.',
  homeBeginSession: 'Begin workout',
  homeViewProgram: 'View program',
  homeQuickActions: 'QUICK ACTIONS',
  homeQuickWorkout: 'Log workout',
  homeQuickCardio: 'Add cardio',
  homeQuickProgress: 'Add measurement',
  homeWorkoutsSummary: 'Workouts • 30 days',
  homeCardioSummary: 'Cardio • 30 days',
  homeBodySummary: 'Body weight',
  homeCompanionIdle: 'Ready when you are.',
  homeCompanionTraining: 'Locked in. Keep pushing.',
  homeCompanionSuccess: 'Session complete. Well earned.',
  homeCompanionMilestone: 'New milestone reached!',
  homeNoWorkouts30: 'No workouts in the last 30 days',
  homeNoCardio30: 'No cardio in the last 30 days',
  homeNoBody30: 'No body measurements yet',
  trainTitle: 'Training Programs',
  trainNoAssignments: 'No assignments yet',
  trainNoAssignmentsSub: 'Assigned programs from your coach appear here.',
  trainActive: 'Active',
  trainUpcoming: 'Upcoming',
  trainEnded: 'Ended',
  trainDays: 'days',
  trainStarts: 'Starts',
  trainEnds: 'Ends',
  openProgram: 'Open program',
  exercisesCount: 'exercises',
  targetSetsShort: 'Sets',
  targetRepsShort: 'Reps',
  targetWeightShort: 'kg',
  restShort: 'Rest',
  dayLabel: 'Day',
  startSession: 'Start session',
  sessionHistory: 'Session history',
  sessionNotes: 'Notes',
  notesHint: 'How did it feel? Any adjustments?',
  finishSession: 'Finish session',
  saveDraft: 'Save in progress',
  deleteSession: 'Delete session',
  deleteSessionConfirm: 'Delete this training session? Logged sets will be removed.',
  sessionsEmpty: 'No sessions yet',
  sessionsEmptySub: 'Start a session from one of your program days.',
  sessionStartedAt: 'Started',
  sessionCompletedAt: 'Completed',
  completedBadge: 'Completed',
  pendingBadge: 'In progress',
  noSetsSelected: 'Log at least one set before saving.',
  saveSessionFailed: 'Could not save session. Try again.',
  cardioTitle: 'Cardio',
  addCardio: 'Add cardio',
  editCardio: 'Edit cardio',
  activityType: 'ACTIVITY',
  activityRun: 'Run',
  activityWalk: 'Walk',
  activityCycling: 'Cycling',
  activitySwimming: 'Swimming',
  activityRowing: 'Rowing',
  activityOther: 'Other',
  durationMinutes: 'DURATION (MINUTES)',
  distanceKm: 'DISTANCE (KM)',
  avgHeartRate: 'AVG HEART RATE',
  performedAt: 'PERFORMED AT',
  deleteEntry: 'Delete entry',
  deleteEntryConfirm: 'Delete this cardio entry?',
  cardioEmpty: 'No cardio logged',
  cardioEmptySub: 'Track your runs, rides and swims to see the full picture.',
  progressTitle: 'Progress',
  range7: '7d',
  range30: '30d',
  range90: '90d',
  range365: '1y',
  chartBodyWeight: 'Body weight',
  chartWorkoutVolume: 'Workout volume',
  chartCardioDuration: 'Cardio duration',
  addMeasurement: 'Add measurement',
  editMeasurement: 'Edit measurement',
  weightKg: 'WEIGHT (KG)',
  bodyFatPercentage: 'BODY FAT (%)',
  waistCm: 'WAIST (CM)',
  chestCm: 'CHEST (CM)',
  armCm: 'ARM (CM)',
  measuredOn: 'MEASURED ON',
  measurementsHeader: 'MEASUREMENTS',
  measurementsEmpty: 'No measurements yet',
  measurementsEmptySub: 'Log your weight and measurements to see trends over time.',
  deleteMeasurement: 'Delete measurement',
  deleteMeasurementConfirm: 'Delete this measurement record?',
  settingsTitle: 'Settings',
  languageSection: 'LANGUAGE',
  languageEnglish: 'English',
  languageArabic: 'العربية',
  apiSection: 'API CONNECTION',
  apiBaseUrl: 'API base URL',
  saveApiUrl: 'Save API URL',
  savedNote: 'Saved.',
  signOut: 'Sign out',
  signOutConfirm: 'Sign out? Your local session will be discarded.',
  aboutSection: 'ABOUT',
  appVersionLabel: 'One More Rep • Trainee App v1.0 (P5)',
  profileNote: 'Profile management arrives in the next release (P7).',
  ok: 'OK',
  cancel: 'Cancel',
  delete: 'Delete',
  retry: 'Retry',
  requiredField: 'This field is required.',
  invalidNumber: 'Enter a valid number.',
  seeAll: 'See all',
  noDataForPeriod: 'No data for this period',
  errorGeneric: 'Something went wrong.',
  loadingLabel: 'Loading…',
  today: 'Today',
  last30Days: 'LAST 30 DAYS',
  p5LoadingProfile: 'Loading your profile…',
);

const _ar = AppStrings(
  'ar',
  splashCta: 'ادخل الحلبة',
  splashMotto: 'القوة  •  الانضباط  •  التقدم',
  splashTagline: 'مبني بالانضباط',
  signInTitle: 'أهلاً بعودتك',
  signInSubtitle: 'سجّل دخولك لتواصل تدريبك.',
  emailLabel: 'البريد الإلكتروني',
  passwordLabel: 'كلمة المرور',
  advancedSection: 'خيارات متقدمة',
  apiUrlLabel: 'عنوان الـ API',
  apiUrlHint: 'http://10.0.2.2:8000/api/v1',
  signInButton: 'تسجيل الدخول',
  signingIn: 'جارٍ تسجيل الدخول…',
  errInvalidEmail: 'أدخل بريداً إلكترونياً صحيحاً.',
  errPasswordRequired: 'أدخل كلمة المرور.',
  errWrongCredentials: 'فشل تسجيل الدخول. تحقق من بياناتك ومن عنوان الـ API.',
  navHome: 'الرئيسية',
  navTrain: 'التدريب',
  navCardio: 'الكارديو',
  navProgress: 'التقدم',
  navSettings: 'الإعدادات',
  greetingMorning: 'صباح الخير',
  greetingAfternoon: 'مساء الخير',
  greetingEvening: 'طاب مساك',
  greetingNight: 'تتدرب في الوقت المتأخر',
  homeActiveProgram: 'البرنامج النشط',
  homeNoProgram: 'لا يوجد برنامج نشط بعد',
  homeNoProgramSub: 'سيعين لك مدربك برنامجاً قريباً. حان وقت التركيز.',
  homeBeginSession: 'ابدأ التدريب',
  homeViewProgram: 'عرض البرنامج',
  homeQuickActions: 'إجراءات سريعة',
  homeQuickWorkout: 'سجّل تمريناً',
  homeQuickCardio: 'أضف كارديو',
  homeQuickProgress: 'أضف قياساً',
  homeWorkoutsSummary: 'تمارين • ٣٠ يوماً',
  homeCardioSummary: 'كارديو • ٣٠ يوماً',
  homeBodySummary: 'وزن الجسم',
  homeCompanionIdle: 'جاهز متى ما كنت مستعداً.',
  homeCompanionTraining: 'تركيز كامل. واصل الدفع.',
  homeCompanionSuccess: 'اكتمل التمرين. جهود تستحق التقدير.',
  homeCompanionMilestone: 'تم الوصول إلى مستوى جديد!',
  homeNoWorkouts30: 'لا تمارين في آخر ٣٠ يوماً',
  homeNoCardio30: 'لا كارديو في آخر ٣٠ يوماً',
  homeNoBody30: 'لا قياسات جسم بعد',
  trainTitle: 'برامج التدريب',
  trainNoAssignments: 'لا إسنادات بعد',
  trainNoAssignmentsSub: 'تظهر هنا برامجك المُسندة من مدربك.',
  trainActive: 'نشط',
  trainUpcoming: 'قادم',
  trainEnded: 'منتهي',
  trainDays: 'أيام',
  trainStarts: 'يبدأ',
  trainEnds: 'ينتهي',
  openProgram: 'افتح البرنامج',
  exercisesCount: 'تمارين',
  targetSetsShort: 'مجموعات',
  targetRepsShort: 'عدد',
  targetWeightShort: 'كغ',
  restShort: 'راحة',
  dayLabel: 'يوم',
  startSession: 'ابدأ جلسة',
  sessionHistory: 'سجل الجلسات',
  sessionNotes: 'ملاحظات',
  notesHint: 'كيف كان حاسسك؟ أي تعديلات؟',
  finishSession: 'إنهاء الجلسة',
  saveDraft: 'حفظ كجلسة جارية',
  deleteSession: 'حذف الجلسة',
  deleteSessionConfirm: 'حذف جلسة التدريب هذه؟ ستُحذف المجموعات المسجلة.',
  sessionsEmpty: 'لا جلسات بعد',
  sessionsEmptySub: 'ابدأ جلسة من أحد أيام برنامجك.',
  sessionStartedAt: 'بدأت',
  sessionCompletedAt: 'اكتملت',
  completedBadge: 'مكتملة',
  pendingBadge: 'جارية',
  noSetsSelected: 'سجّل مجموعة واحدة على الأقل قبل الحفظ.',
  saveSessionFailed: 'تعذر حفظ الجلسة. حاول مرة أخرى.',
  cardioTitle: 'الكارديو',
  addCardio: 'أضف كارديو',
  editCardio: 'تعديل الكارديو',
  activityType: 'النشاط',
  activityRun: 'جري',
  activityWalk: 'مشي',
  activityCycling: 'دراجة',
  activitySwimming: 'سباحة',
  activityRowing: 'تجديف',
  activityOther: 'أخرى',
  durationMinutes: 'المدة (دقائق)',
  distanceKm: 'المسافة (كم)',
  avgHeartRate: 'متوسط النبض',
  performedAt: 'وقت التمرين',
  deleteEntry: 'حذف السجل',
  deleteEntryConfirm: 'حذف سجل الكارديو هذا؟',
  cardioEmpty: 'لا كارديو مسجل',
  cardioEmptySub: 'تابع جريك ودراجتك وسبحتك لترى الصورة كاملة.',
  progressTitle: 'التقدم',
  range7: '٧ أيام',
  range30: '٣٠ يوماً',
  range90: '٩٠ يوماً',
  range365: 'سنة',
  chartBodyWeight: 'وزن الجسم',
  chartWorkoutVolume: 'حجم التمارين',
  chartCardioDuration: 'مدة الكارديو',
  addMeasurement: 'أضف قياساً',
  editMeasurement: 'تعديل القياس',
  weightKg: 'الوزن (كغ)',
  bodyFatPercentage: 'نسبة الدهون (%)',
  waistCm: 'الخصر (سم)',
  chestCm: 'الصدر (سم)',
  armCm: 'الذراع (سم)',
  measuredOn: 'تاريخ القياس',
  measurementsHeader: 'القياسات',
  measurementsEmpty: 'لا قياسات بعد',
  measurementsEmptySub: 'سجّل وزنك وقياساتك لترى الاتجاه عبر الزمن.',
  deleteMeasurement: 'حذف القياس',
  deleteMeasurementConfirm: 'حذف سجل القياس هذا؟',
  settingsTitle: 'الإعدادات',
  languageSection: 'اللغة',
  languageEnglish: 'English',
  languageArabic: 'العربية',
  apiSection: 'الاتصال بالـ API',
  apiBaseUrl: 'عنوان الـ API',
  saveApiUrl: 'حفظ العنوان',
  savedNote: 'تم الحفظ.',
  signOut: 'تسجيل الخروج',
  signOutConfirm: 'تسجيل الخروج؟ سيتم إسقاط جلستك المحلية.',
  aboutSection: 'حول التطبيق',
  appVersionLabel: 'One More Rep • تطبيق المتدرب v1.0 (P5)',
  profileNote: 'إدارة الملف الشخصي ستتوفر في الإصدار القادم (P7).',
  ok: 'حسناً',
  cancel: 'إلغاء',
  delete: 'حذف',
  retry: 'إعادة المحاولة',
  requiredField: 'هذا الحقل مطلوب.',
  invalidNumber: 'أدخل رقماً صحيحاً.',
  seeAll: 'عرض الكل',
  noDataForPeriod: 'لا بيانات لهذه الفترة',
  errorGeneric: 'حدث خطأ ما.',
  loadingLabel: 'جارٍ التحميل…',
  today: 'اليوم',
  last30Days: 'آخر ٣٠ يوماً',
  p5LoadingProfile: 'جارٍ تحميل ملفك…',
);

/// Supported locales: English (LTR) and Arabic (RTL).
const supportedLocales = [Locale('en'), Locale('ar')];
