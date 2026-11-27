// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'HealthWallet.me';

  @override
  String get homeTitle => 'Головна';

  @override
  String get profileTitle => 'Профіль';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get welcomeMessage => 'Ласкаво просимо до HealthWallet.me!';

  @override
  String get onboardingBack => 'Назад';

  @override
  String get onboardingGetStarted => 'Почати';

  @override
  String get onboardingNext => 'Далі';

  @override
  String get onboardingWelcomeTitle => 'твій медичний гаманець!';

  @override
  String get onboardingWelcomeSubtitle =>
      '<link>HealthWallet.me</link> уже підключається до понад 100 000 медичних закладів у США, і ми розширюємося на нові країни.';

  @override
  String get onboardingWelcomeDescription =>
      'Додавайте записи від будь-якого постачальника медичних послуг, імпортуйте документи вручну або попросіть підтримку для вашої країни.';

  @override
  String get onboardingRecordsTitle => 'Ваше здоров\'я — завжди синхронізоване';

  @override
  String get onboardingRecordsSubtitle =>
      '<link>HealthWallet.me</link> пропонує гнучкі способи зібрати всю вашу медичну історію:';

  @override
  String get onboardingRecordsDescription =>
      '• Скануйте документи камерою телефона\n• Завантажуйте PDF, зображення чи лабораторні файли напряму\n• Імпортуйте записи, поділившись напряму з <link>HealthWallet.me</link> з будь-якого застосунку на смартфоні.\n• Скануйте QR-код Fasten Health OnPrem і отримайте всі записи з медичних систем США у свій гаманець.';

  @override
  String get onboardingRecordsContent =>
      '• Скануйте документи камерою телефона\n• Завантажуйте PDF, зображення чи лабораторні файли напряму\n• Імпортуйте записи, поділившись напряму з <link>HealthWallet.me</link> з будь-якого застосунку на смартфоні.\n• Скануйте QR-код <link>Fasten Health OnPrem</link> і отримайте всі записи з медичних систем США у свій гаманець.';

  @override
  String get onboardingRecordsBottom =>
      'Усе безпечно впорядковано на вашому пристрої.';

  @override
  String get onboardingRequestIntegration => 'Запросити інтеграцію';

  @override
  String get onboardingScanButton => 'Сканувати';

  @override
  String get onboardingSyncTitle => 'Безпека та конфіденційність';

  @override
  String get onboardingSyncSubtitle =>
      '<link>HealthWallet.me</link> створено з пріоритетом конфіденційності. Ваші медичні дані зашифровані та зберігаються лише на телефоні, ніколи на хмарних серверах.';

  @override
  String get onboardingSyncDescription =>
      'Переглядайте історію здоров\'я в режимі польоту, за кордоном чи без інтернету — ваші записи завжди з вами. Додайте додатковий рівень безпеки, увімкнувши біометричну автентифікацію.';

  @override
  String get onboardingBiometricText =>
      'Ви можете захистити HealthWallet біометричним захистом, як-от Face ID чи сканування відбитка пальця.';

  @override
  String get homeHi => 'Привіт, ';

  @override
  String get homeLastSynced => 'Остання синхронізація: ';

  @override
  String get homeNever => 'Ніколи';

  @override
  String get homeVitalSigns => 'Показники';

  @override
  String get homeOverview => 'Медичні записи';

  @override
  String get homeSource => 'Джерело:';

  @override
  String get homeAll => 'Усі';

  @override
  String get homeRecentRecords => 'Останні записи';

  @override
  String get homeViewAll => 'Переглянути всі';

  @override
  String get homeNA => 'Н/Д';

  @override
  String get bluetoothRequired =>
      'Увімкніть Bluetooth, щоб користуватися Спільним доступом поблизу';

  @override
  String get dashboardTitle => 'Панель';

  @override
  String get recordsTitle => 'Записи';

  @override
  String get goToRecords => 'Перейти до записів';

  @override
  String get syncTitle => 'Синхронізація';

  @override
  String get syncSuccessful => 'Синхронізацію завершено!';

  @override
  String get syncDataLoadedSuccessfully =>
      'Ваші медичні записи синхронізовано. Вас буде перенаправлено на головну сторінку.';

  @override
  String get cancelSyncTitle => 'Скасувати синхронізацію?';

  @override
  String get cancelSyncMessage =>
      'Ви впевнені, що хочете скасувати синхронізацію? Це зупинить поточний процес синхронізації.';

  @override
  String get yesCancel => 'Так, скасувати';

  @override
  String get continueSync => 'Продовжити синхронізацію';

  @override
  String get syncAgain => 'Синхронізувати знову';

  @override
  String get syncFailed => 'Не вдалося синхронізувати: ';

  @override
  String get tryAgain => 'Спробувати знову';

  @override
  String get syncedAt => 'Синхронізовано: ';

  @override
  String get pasteSyncData => 'Вставити дані синхронізації';

  @override
  String get submit => 'Надіслати';

  @override
  String get hideManualEntry => 'Приховати ручне введення';

  @override
  String get enterDataManually => 'Ввести дані вручну';

  @override
  String get medicalRecords => 'Медичні записи';

  @override
  String get searchRecordsHint => 'Пошук записів, лікарів, місць...';

  @override
  String get detailsFor => 'Деталі для ';

  @override
  String get patientId => 'НЗ: ';

  @override
  String get age => 'Вік';

  @override
  String get sex => 'Стать';

  @override
  String get bloodType => 'Група крові';

  @override
  String get lastSyncedProfile => 'Остання синхронізація: 2 години тому';

  @override
  String get syncLatestRecords =>
      'Синхронізуйте найновіші медичні записи від вашого постачальника медичних послуг.';

  @override
  String get scanToSync => 'Сканувати для синхронізації';

  @override
  String get theme => 'Тема';

  @override
  String get pleaseAuthenticate =>
      'Будь ласка, автентифікуйтеся, щоб продовжити';

  @override
  String get authenticate => 'Автентифікація';

  @override
  String get bypass => 'Пропустити';

  @override
  String get onboardingAuthTitle => 'Увімкнути біометричну автентифікацію';

  @override
  String get onboardingAuthDescription =>
      'Додайте додатковий рівень безпеки до вашого акаунта, увімкнувши біометричну автентифікацію.';

  @override
  String get onboardingAuthEnable => 'Увімкнути зараз';

  @override
  String get onboardingAuthSkip => 'Пропустити поки що';

  @override
  String get biometricAuthentication => 'Біометрична автентифікація';

  @override
  String get privacyPolicy => 'Політика конфіденційності';

  @override
  String get setupDeviceSecurity => 'Налаштуйте безпеку пристрою';

  @override
  String get deviceSecurityMessage =>
      'На вашому пристрої не налаштовано захист. Для вашої безпеки налаштуйте захист пристрою перед використанням цього застосунку:';

  @override
  String get deviceSettingsStep1 => 'Перейдіть до Налаштувань пристрою';

  @override
  String get deviceSettingsStep2 =>
      'Відкрийте розділ Безпека або Блокування екрана';

  @override
  String get deviceSettingsStep3 =>
      'Налаштуйте блокування екрана (PIN-код, графічний ключ або пароль)';

  @override
  String get deviceSettingsStep4 =>
      'За бажанням додайте розблокування відбитком пальця чи обличчям для зручності';

  @override
  String get deviceSecurityReturnMessage =>
      'Після налаштування захисту пристрою поверніться до цього застосунку та спробуйте знову.';

  @override
  String get cancel => 'Скасувати';

  @override
  String get openSettings => 'Відкрити налаштування';

  @override
  String get settingsNotAvailable => 'Налаштування недоступні';

  @override
  String get settingsNotAvailableMessage =>
      'Не вдалося автоматично відкрити налаштування пристрою. Будь ласка, вручну:\n\n1. Відкрийте Налаштування\n2. Перейдіть до Безпека → Біометрія\n3. Додайте розблокування відбитком пальця чи обличчям\n4. Поверніться до цього застосунку та спробуйте знову';

  @override
  String get ok => 'OK';

  @override
  String get scanCode => 'Сканувати код';

  @override
  String get or => 'або';

  @override
  String get manualSyncMessage => 'Необроблений QR-код';

  @override
  String get pasteSyncDataHint => 'Вставте необроблений QR-код';

  @override
  String get connect => 'Підключитися';

  @override
  String get scanNewQRCode => 'Сканувати новий QR-код';

  @override
  String get loadDemoData => 'Завантажити демо-дані';

  @override
  String get syncData => 'Синхронізувати дані';

  @override
  String get noMedicalRecordsYet => 'Медичних записів ще немає';

  @override
  String noRecordTypeYet(Object recordType) {
    return '$recordType ще немає';
  }

  @override
  String get loadDemoDataMessage =>
      'Завантажте демо-дані, щоб дослідити застосунок, або синхронізуйте свої реальні медичні записи';

  @override
  String syncDataMessage(Object recordType) {
    return 'Синхронізуйте чи оновіть дані, щоб переглянути записи $recordType';
  }

  @override
  String get retry => 'Повторити';

  @override
  String get pleaseEnterSourceName => 'Будь ласка, введіть назву джерела';

  @override
  String get selectBirthDate => 'Виберіть дату народження';

  @override
  String get years => 'років';

  @override
  String get male => 'Чоловіча';

  @override
  String get female => 'Жіноча';

  @override
  String get preferNotToSay => 'Не хочу вказувати';

  @override
  String get errorUpdatingSourceLabel => 'Помилка оновлення назви джерела';

  @override
  String get noChangesDetected => 'Змін не виявлено';

  @override
  String get pleaseSelectBirthDate => 'Будь ласка, виберіть дату народження';

  @override
  String get errorSavingPatientData => 'Помилка збереження даних пацієнта';

  @override
  String get walletHolder => 'Власник гаманця';

  @override
  String get walletHolderDescription =>
      'Цей пацієнт є основним власником цього медичного гаманця';

  @override
  String get getStarted => 'Почати';

  @override
  String get failedToUpdateDisplayName =>
      'Не вдалося оновити відображуване ім\'я';

  @override
  String get actionCannotBeUndone => 'Цю дію неможливо скасувати.';

  @override
  String get deleteRecordConfirm =>
      'Ви впевнені, що хочете видалити цей запис?';

  @override
  String get deleteNoteConfirm => 'Ви впевнені, що хочете видалити цю нотатку?';

  @override
  String get deleteAttachmentConfirm =>
      'Ви впевнені, що хочете видалити це вкладення?';

  @override
  String deleteRecordsConfirm(int count) {
    return 'Ви впевнені, що хочете видалити $count елементів?';
  }

  @override
  String confirmDeleteFile(Object filename) {
    return 'Ви впевнені, що хочете видалити \"$filename\"?';
  }

  @override
  String selectAtLeastOne(Object type) {
    return 'Виберіть принаймні один $type, щоб продовжити.';
  }

  @override
  String get editSourceLabel => 'Редагувати назву джерела';

  @override
  String get saveDetails => 'Зберегти деталі';

  @override
  String get editDetails => 'Редагувати деталі';

  @override
  String get done => 'Готово';

  @override
  String get page => 'Сторінка';

  @override
  String get reorderPages => 'Змінити порядок сторінок';

  @override
  String get attachments => 'Вкладення';

  @override
  String get noFilesAttached => 'До цього запису не додано файлів';

  @override
  String get attachFile => 'Прикріпити файл';

  @override
  String get overview => 'Огляд';

  @override
  String get recentRecords => 'Останні записи';

  @override
  String chooseToDisplay(Object type) {
    return 'Виберіть $type, які хочете бачити на панелі.';
  }

  @override
  String get displayName => 'Відображуване ім\'я';

  @override
  String get bloodTypeAPositive => 'A позитивна';

  @override
  String get bloodTypeANegative => 'A негативна';

  @override
  String get bloodTypeBPositive => 'B позитивна';

  @override
  String get bloodTypeBNegative => 'B негативна';

  @override
  String get bloodTypeABPositive => 'AB позитивна';

  @override
  String get bloodTypeABNegative => 'AB негативна';

  @override
  String get bloodTypeOPositive => 'O позитивна';

  @override
  String get bloodTypeONegative => 'O негативна';

  @override
  String get serverError => 'Щось пішло не так на сервері';

  @override
  String get serverTimeout => 'Час очікування сервера вичерпано';

  @override
  String get connectionError => 'Помилка з\'єднання';

  @override
  String get unknownSource => 'Невідоме джерело';

  @override
  String get synchronization => 'Синхронізація';

  @override
  String get syncMedicalRecords => 'Синхронізувати медичні записи';

  @override
  String get syncLatestMedicalRecords =>
      'Синхронізуйте найновіші медичні записи від постачальника медичних послуг за допомогою безпечного JWT-токена.';

  @override
  String get neverSynced => 'Ніколи не синхронізовано';

  @override
  String get lastSynced => 'Остання синхронізація';

  @override
  String get tapToSelectPatient => 'Торкніться, щоб вибрати пацієнта';

  @override
  String get preferences => 'Налаштування';

  @override
  String get version => 'Версія';

  @override
  String get on => 'УВІМК.';

  @override
  String get off => 'ВИМК.';

  @override
  String get confirmDisableBiometric =>
      'Ви впевнені, що хочете вимкнути біометричну автентифікацію (FaceID / код-пароль)?';

  @override
  String get disable => 'Вимкнути';

  @override
  String get continueButton => 'Продовжити';

  @override
  String get enableBiometricAuth =>
      'Увімкнути біометричну автентифікацію (FaceID / код-пароль)';

  @override
  String get disableBiometricAuth =>
      'Вимкнути біометричну автентифікацію (FaceID / код-пароль)';

  @override
  String get patient => 'Пацієнт';

  @override
  String get noPatientsFound => 'Пацієнтів не знайдено';

  @override
  String get id => 'ID';

  @override
  String get gender => 'Стать';

  @override
  String get loading => 'Завантаження...';

  @override
  String get source => 'Джерело';

  @override
  String get showAll => 'Показати всі';

  @override
  String get records => 'Записи';

  @override
  String get vitals => 'Показники';

  @override
  String get selectAll => 'Вибрати все';

  @override
  String get clearAll => 'Очистити все';

  @override
  String get save => 'Зберегти';

  @override
  String get noRecordsFound => 'Записів не знайдено';

  @override
  String get noRecords => 'Немає записів';

  @override
  String get tryDifferentKeywords =>
      'Спробуйте пошукати з іншими ключовими словами';

  @override
  String get clearAllFilters => 'Очистити все';

  @override
  String get syncingData => 'Синхронізація даних';

  @override
  String get syncingMessage =>
      'Це може зайняти деякий час. Будь ласка, зачекайте.';

  @override
  String get scanQRMessage =>
      'Відскануйте QR-код із вашого сервера Fasten Health, щоб створити нове з\'єднання для синхронізації.';

  @override
  String get viewAll => 'Переглянути всі';

  @override
  String get vitalSigns => 'Показники життєдіяльності';

  @override
  String get longPressToReorder =>
      'Утримуйте, щоб переміщати та змінювати порядок карток, або відфільтруйте, які з них показувати на панелі.';

  @override
  String get finishProcessing => 'Завершити обробку';

  @override
  String get finishProcessingMessage =>
      'Ви впевнені, що хочете завершити цей сеанс обробки?';

  @override
  String get finishProcessingWarning => 'Це очистить поточний сеанс.';

  @override
  String get fieldCannotBeEmpty => 'Це поле не може бути порожнім';

  @override
  String get selectDate => 'Виберіть дату';

  @override
  String get attachToEncounter => 'Прикріпити до візиту';

  @override
  String get continueProcessing => 'Продовжити обробку';

  @override
  String get recordsSavedTitle => 'Успішно збережено';

  @override
  String get recordsSavedMessage => 'Ваші медичні записи успішно збережено.';

  @override
  String get whatNextQuestion => 'Що б ви хотіли зробити далі?';

  @override
  String get continueScanning => 'Продовжити сканування';

  @override
  String get effectiveDate => 'Дата набрання чинності';

  @override
  String get privacyIntro => 'Ваша конфіденційність — наш найвищий пріоритет.';

  @override
  String get privacyDescription =>
      '— це простий і безпечний інструмент, створений, щоб допомогти вам легко впорядковувати медичні записи безпосередньо на вашому пристрої. Ця політика пояснює наше зобов\'язання щодо вашої конфіденційності: ми не збираємо ваші дані та не відстежуємо вас. Ви повністю контролюєте ситуацію.';

  @override
  String get corePrinciple =>
      'Наш основний принцип: ваші дані залишаються на вашому пристрої';

  @override
  String get whatInformationHandled => 'Яка інформація обробляється?';

  @override
  String get informationWeDoNotCollect =>
      'Інформація, яку ми не збираємо та до якої не маємо доступу';

  @override
  String get informationYouManage => 'Інформація, якою ви керуєте';

  @override
  String get importingDocuments => 'Імпорт документів із вашого пристрою';

  @override
  String get connectingFastenHealth => 'Підключення до FastenHealth OnPrem';

  @override
  String get howInformationUsed => 'Як використовується ваша інформація';

  @override
  String get dataStorageSecurity => 'Зберігання, безпека та обмін даними';

  @override
  String get childrensPrivacy => 'Конфіденційність дітей';

  @override
  String get changesToPolicy => 'Зміни до цієї Політики конфіденційності';

  @override
  String get contactUs => 'Зв\'яжіться з нами';

  @override
  String get builtWithLove => 'Створено з любов\'ю командою Life Value!';

  @override
  String get sourceName => 'Назва джерела';

  @override
  String get provideCustomLabel => 'Надайте власну назву для:';

  @override
  String get success => 'Успішно';

  @override
  String get demoDataLoadedSuccessfully =>
      'Демо-дані успішно завантажено. Вас буде перенаправлено на головну сторінку.';

  @override
  String get documentScanTitle => 'Сканувати';

  @override
  String get onboardingAiModelTitle => 'Увімкнути AI-модель';

  @override
  String get onboardingAiModelDescription =>
      'Завантажте безпечну AI-модель на пристрої, щоб автоматично аналізувати та впорядковувати ваші медичні записи. Виберіть один із двох варіантів залежно від ваших потреб і можливостей пристрою. Це одноразове налаштування.\n\n**Ваші дані залишаються приватними на вашому пристрої.**';

  @override
  String get onboardingAiModelSubtitle => 'Відкрийте сканування на базі ШІ';

  @override
  String get aiModelReady => 'ШІ готовий! Ви можете почати сканування.';

  @override
  String get aiModelDownloading => 'Завантаження...';

  @override
  String get aiModelEnableDownload => 'Вибрати й завантажити';

  @override
  String get aiModelError => 'Не вдалося перевірити. Спробуйте знову.';

  @override
  String get aiModelMissing => 'Не завантажено.';

  @override
  String get aiModelTitle => 'Завантажити AI-модель';

  @override
  String get aiModelUnlockTitle => 'Відкрийте сканування на базі ШІ';

  @override
  String get aiModelUnlockDescription =>
      'Щоб автоматично читати та впорядковувати ваші медичні документи, ця функція використовує безпечну AI-модель на пристрої.\n\n**Ваші дані залишаються приватними на вашому пристрої.**';

  @override
  String get aiModelDownloadInfo =>
      'Щоб почати, виберіть і завантажте один із двох доступних AI-варіантів. Це одноразове налаштування.';

  @override
  String get setup => 'Налаштування';

  @override
  String get patientSetupTitle => 'Налаштуйте свій профіль';

  @override
  String get patientSetupSubtitle =>
      'Персоналізуйте свій медичний гаманець своєю інформацією';

  @override
  String get onboardingSetupTitle => 'Налаштувати мій медичний гаманець';

  @override
  String get onboardingSetupBody =>
      'Створіть свій особистий медичний профіль, щоб почати користуватися HealthWallet';

  @override
  String get onboardingDemoTitle => 'Спробувати демо-дані';

  @override
  String get onboardingDemoBody =>
      'Дослідіть застосунок на прикладі медичних записів, щоб побачити, як він працює';

  @override
  String get onboardingSyncTitle2 => 'Синхронізуйте свої записи';

  @override
  String get onboardingSyncBody =>
      'Підключіться до своїх постачальників медичних послуг, щоб імпортувати реальні медичні записи';

  @override
  String get givenName => 'Ім\'я';

  @override
  String get familyName => 'Прізвище';

  @override
  String get skipForNow => 'Пропустити поки що';

  @override
  String get setUpProfile => 'Налаштувати';

  @override
  String get useDefaults => 'За замовчуванням';

  @override
  String get syncPlaceholderTutorialStep1 =>
      'Заповніть свій профіль, щоб відкрити всі функції.';

  @override
  String get syncPlaceholderTutorialStep2 =>
      'Не готові до імпорту? Завантажте демо-дані, щоб побачити застосунок у дії.';

  @override
  String get syncPlaceholderTutorialStep3 =>
      'Тримайте настільний і мобільний гаманець актуальними.';

  @override
  String get tapToContinue => 'Торкніться, щоб продовжити';

  @override
  String get homeOnboardingReorderMessage =>
      'Утримуйте, щоб змінити їхній порядок на власний розсуд.';

  @override
  String get processing => 'Обробка';

  @override
  String get sessionNotFound => 'Сеанс не знайдено!';

  @override
  String get preparingPreview => 'Підготовка попереднього перегляду...';

  @override
  String get processingFailed => 'Не вдалося обробити';

  @override
  String get processingCancelled => 'Обробку скасовано';

  @override
  String get processingBasicDetails => 'Обробка основних даних...';

  @override
  String get processingPages => 'Обробка сторінок...';

  @override
  String get extractingPatientInfo =>
      'Вилучення інформації про пацієнта та візит.';

  @override
  String get pleaseWait => 'Це може зайняти деякий час. Будь ласка, зачекайте.';

  @override
  String get focusMode => 'Режим фокусування';

  @override
  String get onlyOneSessionAtTime =>
      'Одночасно може виконуватися лише один сеанс обробки';

  @override
  String get aiModelNotAvailable => 'Розумне сканування недоступне';

  @override
  String get addResources => 'Додати ресурси';

  @override
  String get addResourcesTitle => 'Додати ресурси';

  @override
  String get chooseResourcesDescription =>
      'Виберіть ресурси, які хочете додати для обробки.';

  @override
  String get add => 'Додати';

  @override
  String get allergyIntolerance => 'Алергічна непереносимість';

  @override
  String get condition => 'Стан здоров\'я';

  @override
  String get diagnosticReport => 'Діагностичний звіт';

  @override
  String get medicationStatement => 'Запис про ліки';

  @override
  String get observation => 'Спостереження';

  @override
  String get organization => 'Організація';

  @override
  String get practitioner => 'Лікар';

  @override
  String get procedure => 'Процедура';

  @override
  String get tapToViewProgress => 'Торкніться будь-де, щоб переглянути прогрес';

  @override
  String screenWillDarkenInSeconds(int remainingSeconds) {
    return 'Екран потемніє через $remainingSeconds секунд.';
  }

  @override
  String get screenWillDarkenInZeroSeconds => 'Екран потемніє через 0 секунд.';

  @override
  String get whileDocumentsProcessed => 'Поки ваші документи обробляються:';

  @override
  String get doNotLockScreen =>
      'Не блокуйте екран і не виходьте із застосунку.';

  @override
  String get plugInCharger => 'Підключіть зарядний пристрій.';

  @override
  String get exitFocusMode => 'Вийти з режиму фокусування';

  @override
  String get chargerPluggedIn => 'Зарядний пристрій підключено.';

  @override
  String get plugInChargerEllipsis => 'Підключіть зарядний пристрій...';

  @override
  String get processingFailedCapacity =>
      'Документ завеликий для поточного розміру AI-контексту.';

  @override
  String get processingFailedCapacitySuggestion =>
      'Торкніться іконки налаштувань вище та збільште розмір контексту до 2048 або більше, потім повторіть спробу.';

  @override
  String get increaseAiModelCapacity => 'Збільшити AI-потужність';

  @override
  String get goBack => 'Назад';

  @override
  String get aiModelManage => 'Керувати AI-варіантами';

  @override
  String get aiModelNotSelected => 'Варіант не вибрано';

  @override
  String get aiModelSelect => 'Вибрати варіант';

  @override
  String get aiSettings => 'Налаштування ШІ';

  @override
  String get aiSettingsDescription =>
      'Налаштуйте продуктивність ШІ для вашого пристрою. Рекомендовані значення попередньо вибрано.';

  @override
  String get setAiTokensUsage => 'Налаштувати використання AI-токенів';

  @override
  String get tokenUsageDescription =>
      'Керуйте тим, скільки обчислювальних ресурсів може використовувати ШІ. Вища потужність дозволяє більші файли та складніші завдання, але використовує більше ресурсів і триває довше.';

  @override
  String get gpuLayersLabel => 'GPU-шари';

  @override
  String get gpuLayersDescription =>
      'Перенесіть шари моделі на GPU для швидшої обробки зображень. Більше шарів = швидше, але більше пам\'яті. Встановіть 0, якщо застосунок аварійно завершується.';

  @override
  String get threadsLabel => 'Потоки CPU';

  @override
  String get threadsDescription =>
      'Кількість потоків CPU для обчислень. Більше потоків = швидше, але більше витрата батареї.';

  @override
  String get recommended => 'Рекомендовано';

  @override
  String get tokenPresetLow => 'Низький';

  @override
  String get tokenPresetLowDescription =>
      'Найкраще для малих файлів і швидких завдань.\nВикористовує найменше ресурсів і обробляє найшвидше.';

  @override
  String get tokenPresetMedium => 'Середній';

  @override
  String get tokenPresetMediumDescription =>
      'Добре для більшості випадків.\nБалансує розмір файлу, час обробки та використання ресурсів.';

  @override
  String get tokenPresetHigh => 'Високий';

  @override
  String get tokenPresetHighDescription =>
      'Найкраще для великих файлів і складної обробки.\nВикористовує більше ресурсів і батареї та триває довше.';

  @override
  String get tokenPresetCustom => 'Власний';

  @override
  String get tokenPresetCustomDescription =>
      'Встановіть власну кількість токенів для використання.';

  @override
  String get setTokens => 'Встановити';

  @override
  String get tokens => 'токенів';

  @override
  String get contextSizeLabel => 'Розмір контексту';

  @override
  String get contextSizeDescription =>
      'Обсяг тексту, який ШІ може обробити за раз. Більший контекст обробляє більші документи, але використовує більше пам\'яті.';

  @override
  String get useVisionLabel => 'Глибоке сканування';

  @override
  String get useVisionDescription =>
      'Читає зображення для глибшого аналізу (напр., рукописний текст). Використовує більше пам\'яті та потребує продуктивнішого пристрою.';

  @override
  String get aiModelNotAvailableForDevice => 'Недоступно для цього телефона';

  @override
  String get aiModelNotAvailableForDeviceDescription =>
      'На жаль, на вашому пристрої недостатньо пам\'яті для запуску AI-моделі. Ви все ще можете користуватися застосунком без розумного сканування.';

  @override
  String get noInternetConnectionTitle => 'Немає підключення до інтернету';

  @override
  String get noInternetConnectionDescription =>
      'Перевірте підключення до інтернету та спробуйте знову.';

  @override
  String get processingStep2NotAvailableTitle =>
      'Глибоке сканування недоступне на цьому пристрої';

  @override
  String get processingStep2NotEnoughRam =>
      'На цьому пристрої недостатньо пам\'яті для глибокого сканування. Обробка на основі тексту все ще доступна і добре працює для більшості документів.';

  @override
  String get emergencyContact => 'Екстрений телефонний контакт';

  @override
  String get emergencyContactHint => 'Номер телефону';

  @override
  String get searchCountry => 'Пошук країни...';

  @override
  String get rotatePage => 'Повернути';

  @override
  String get deletePage => 'Видалити';

  @override
  String get deletePageConfirmTitle => 'Видалити сторінку';

  @override
  String get deletePageConfirmMessage =>
      'Цю сторінку буде видалено з документа.';

  @override
  String get cannotDeleteLastPage => 'Неможливо видалити останню сторінку';

  @override
  String get pageRotated => 'Сторінку повернено';

  @override
  String get regionAndUnits => 'Мова та одиниці';

  @override
  String get country => 'Країна';

  @override
  String get patientModifiedNewWillBeCreated =>
      'Змінено — буде створено нового пацієнта';

  @override
  String patientModifiedUpdating(String name) {
    return 'Зміна існуючого пацієнта: $name';
  }

  @override
  String patientSavingModified(String name) {
    return 'Збереження зміненого пацієнта: $name';
  }

  @override
  String get dropModificationsTitle => 'Скасувати зміни?';

  @override
  String get dropModificationsMessage =>
      'Ваші зміни в полях пацієнта буде відхилено.';

  @override
  String get modifyPatientTitle => 'Змінити пацієнта?';

  @override
  String get modifyPatientMessage =>
      'Це оновить наявний запис пацієнта вашими змінами.';

  @override
  String get scanIdCard => 'Сканувати ID-картку або паспорт';

  @override
  String get scanIdCardDescription =>
      'Автозаповнення з вашого документа. Дані залишаються на вашому пристрої.';

  @override
  String get newLabel => 'Нове';

  @override
  String get newPatient => 'Новий пацієнт';

  @override
  String patientChangedTo(String name) {
    return 'Змінено на: $name';
  }

  @override
  String patientMatchFound(String name) {
    return 'Наявний пацієнт: $name';
  }

  @override
  String get language => 'Мова';

  @override
  String get systemDefault => 'Системна';

  @override
  String get regionUS => 'США';

  @override
  String get regionEurope => 'Європа';

  @override
  String get regionUK => 'Велика Британія';

  @override
  String get medGemmaIncompatibleDevice =>
      'Ця модель потребує більше пам\'яті, ніж доступно на вашому пристрої. Використовуйте натомість стандартну модель.';

  @override
  String get deepScanDownloadTitle => 'Завантажити модель зору';

  @override
  String deepScanDownloadMessage(int size) {
    return 'Глибоке сканування потребує додаткового завантаження (~$size МБ). Завантажити зараз?';
  }

  @override
  String get downloadingVisionModel => 'Завантаження моделі зору...';

  @override
  String get shareUnknownDevice => 'Невідомий пристрій';

  @override
  String get shareViewOnlyBanner =>
      'ТІЛЬКИ ПЕРЕГЛЯД — дані буде видалено, коли ви закриєте сеанс або залишите зону поблизу';

  @override
  String get shareViewOnlyBannerViewing =>
      'ТІЛЬКИ ПЕРЕГЛЯД — дані буде видалено після виходу';

  @override
  String get shareInfoBannerMessage =>
      'Спільні записи доступні лише для перегляду. Усі дані автоматично видаляються після завершення сеансу або закінчення ліміту часу.';

  @override
  String get shareTitle => 'Поділитися';

  @override
  String get shareFindDevices => 'Знайти пристрої';

  @override
  String get shareWaiting => 'Очікування...';

  @override
  String get shareConnectingTitle => 'Підключення';

  @override
  String get shareSending => 'Надсилання';

  @override
  String get shareReceiving => 'Отримання';

  @override
  String get shareSessionActive => 'Сеанс активний';

  @override
  String get shareViewingRecords => 'Перегляд записів';

  @override
  String get shareComplete => 'Завершено';

  @override
  String get shareError => 'Помилка';

  @override
  String get sharePermissionsRequired => 'Потрібні дозволи';

  @override
  String get shareHealthWalletDevice => 'Пристрій HealthWallet';

  @override
  String get shareInvitationDeclined => 'Запрошення відхилено';

  @override
  String get shareSessionComplete => 'Сеанс завершено';

  @override
  String get shareInvitationDeclinedMessage =>
      'Отримувач відхилив ваше запрошення переглянути записи.';

  @override
  String get shareSessionCompleteMessage =>
      'Усі спільні дані безпечно видалено з цього пристрою';

  @override
  String get shareBackHome => 'На головну';

  @override
  String get shareConnectionFailed => 'Не вдалося підключитися';

  @override
  String get shareUnableToConnect =>
      'Не вдалося підключитися. Спробуйте знову.';

  @override
  String get shareNoDataReceived => 'Дані не отримано';

  @override
  String get shareSearchRecords => 'Пошук записів';

  @override
  String get shareNoRecordsMatchFilters => 'Жоден запис не відповідає фільтрам';

  @override
  String get shareNoRecordsAvailable => 'Немає доступних записів';

  @override
  String get shareReceiverViewingRecords => 'Отримувач переглядає записи';

  @override
  String get shareSessionAutoExpire =>
      'Сеанс автоматично завершиться, коли таймер досягне нуля';

  @override
  String get shareRecordsDelivered => 'Записи успішно доставлено';

  @override
  String get shareConnecting => 'Підключення...';

  @override
  String get shareConnectionInterrupted =>
      'З\'єднання перервано, повторне підключення';

  @override
  String get shareSendingRecords => 'Надсилання записів...';

  @override
  String get shareReceivingRecords => 'Отримання записів...';

  @override
  String get shareConfirmExit => 'Підтвердити вихід';

  @override
  String get shareDeleteSharedRecords => 'Видалити спільні записи?';

  @override
  String get shareDeleteWarning =>
      'Спільний запис буде назавжди видалено з цього пристрою. Дію неможливо скасувати';

  @override
  String get shareDeleteAndExit => 'Видалити й вийти';

  @override
  String get shareIncomingTransfer => 'Вхідне передавання';

  @override
  String get shareViewOnlyWarning =>
      'Записи будуть лише для перегляду та автоматично видаляться після виходу';

  @override
  String get shareDecline => 'Відхилити';

  @override
  String get shareAccept => 'Прийняти';

  @override
  String get shareSearchingForDevices => 'Пошук пристроїв поблизу...';

  @override
  String get shareSearchForDevices => 'Пошук пристроїв...';

  @override
  String get shareNoDevicesFound => 'Пристроїв не знайдено';

  @override
  String get shareConnectionIssue => 'Проблема зі з\'єднанням';

  @override
  String get shareWifiDirectUnresponsive =>
      'WiFi Direct не відповідає на цьому пристрої.';

  @override
  String get shareWifiToggleHint =>
      'WiFi Direct не відповідає. Вимкніть і знову увімкніть WiFi, потім торкніться Повторити.';

  @override
  String get shareDiscoveryHint =>
      'Переконайтеся, що на іншому пристрої відкрито застосунок HealthWallet.me';

  @override
  String get shareProximityHint =>
      'Щоб пристрій-отримувач був видимим, у його налаштуваннях має бути увімкнено Спільний доступ поблизу.';

  @override
  String get shareNoRecordsMatchSelectedFilters =>
      'Жоден запис не відповідає вибраним фільтрам';

  @override
  String get shareNoRecordsForAppliedFilters =>
      'Записів для застосованих фільтрів не знайдено';

  @override
  String get shareTryClearingFilters => 'Спробуйте очистити деякі фільтри';

  @override
  String get shareRecordsPageFiltersNoResults =>
      'Фільтри сторінки записів не дали результатів';

  @override
  String get shareImportOrSyncRecords =>
      'Імпортуйте або синхронізуйте записи, щоб поділитися ними';

  @override
  String get shareSessionTime => 'Час сеансу';

  @override
  String get shareSetAsDefault => 'Встановити за замовчуванням';

  @override
  String get shareRecordsButton => 'Поділитися записами';

  @override
  String get shareSelectRecordsToShare =>
      'Виберіть записи для спільного доступу';

  @override
  String get shareEndSession => 'Завершити сеанс';

  @override
  String get shareRequestTenMin => 'Запросити +10 хв';

  @override
  String get shareWaitingForResponse => 'Очікування відповіді...';

  @override
  String get shareAddMoreTime => 'Додати більше часу';

  @override
  String get shareSessionExpiresIn => 'Сеанс завершиться через';

  @override
  String get shareExtensionRequestedTitle => 'Запитано продовження';

  @override
  String get shareHoursLabel => 'год';

  @override
  String get shareMinLabel => 'хв';

  @override
  String shareSelectedCount(int count) {
    return 'Вибрано $count';
  }

  @override
  String shareRecordCount(int recordCount) {
    return '$recordCount запис(ів)';
  }

  @override
  String shareSharedFrom(String source) {
    return 'поділено з $source';
  }

  @override
  String shareFoundDevices(int count) {
    return 'Знайдено $count пристрій(ів)';
  }

  @override
  String shareRetryingCount(int retryCount) {
    return 'Повторна спроба ($retryCount/3)...';
  }

  @override
  String shareDeviceWantsToShare(String deviceName) {
    return '$deviceName хоче поділитися з вами записами';
  }

  @override
  String shareExtensionsUsed(int used, int max) {
    return 'Використано $used/$max продовжень';
  }

  @override
  String shareDurationHoursMinutes(int hours, int minutes) {
    return '$hours год $minutes хв';
  }

  @override
  String shareDurationHours(int hours) {
    return '$hours год';
  }

  @override
  String shareDurationMinutes(int minutes) {
    return '$minutes хв';
  }

  @override
  String shareTimerHoursMinutesSeconds(int hours, int minutes, int seconds) {
    return '$hours год $minutes хв $seconds с';
  }

  @override
  String shareTimerMinutesSeconds(int minutes, int seconds) {
    return '$minutes хв $seconds с';
  }

  @override
  String shareTimerSeconds(int seconds) {
    return '$seconds с';
  }

  @override
  String shareMinuteCount(int minutes) {
    return '$minutes хв';
  }

  @override
  String shareSecondsCount(int seconds) {
    return '$seconds с';
  }

  @override
  String shareExtensionRequestMessage(String peerRole, String duration) {
    return '$peerRole хоче продовжити сеанс на $duration';
  }

  @override
  String shareExtensionDurationRequested(String duration) {
    return 'Запитано $duration';
  }

  @override
  String get aiProviderSectionTitle => 'Провайдер ШІ';

  @override
  String get aiProviderSectionDescription =>
      'Оберіть, як оброблятимуться медичні документи. Хмарний ШІ надсилає дані документів до Google Vertex AI (Gemini). Локальний ШІ залишає все на вашому пристрої.';

  @override
  String get aiProviderAuto => 'Авто';

  @override
  String get aiProviderAutoDescription =>
      'Використовувати хмарний ШІ, коли доступний, інакше — локальний.';

  @override
  String get aiProviderOnDevice => 'На пристрої';

  @override
  String get aiProviderOnDeviceDescription =>
      'Обробляти документи локально завантаженою моделлю.';

  @override
  String get aiProviderCloud => 'Хмара';

  @override
  String get aiProviderCloudDescription =>
      'Обробляти документи через Google Vertex AI (Gemini).';

  @override
  String get aiCloudConsentTitle => 'Дозволити хмарну обробку медичних даних';

  @override
  String get aiCloudConsentDescription =>
      'Зображення та текст документів буде надіслано до Google Vertex AI для обробки. Ці дані можуть залишити ваш пристрій і підпадають під умови Google. Увімкніть, лише якщо ви надаєте згоду.';

  @override
  String get aiCloudConsentRequired =>
      'Для використання хмарного ШІ потрібна згода.';

  @override
  String get aiCloudFallbackTitle => 'Повертатися до локального ШІ';

  @override
  String get aiCloudFallbackDescription =>
      'Якщо хмарний запит не вдасться, повторіть на телефоні (потрібна завантажена модель).';

  @override
  String get aiCloudActiveTitle => 'Хмарний ШІ активний';

  @override
  String get aiCloudActiveDescription =>
      'Документи оброблятимуться в хмарі. Локальна модель не потрібна.';

  @override
  String get aiCloudModelLabel => 'Хмарна модель';

  @override
  String get aiLocalSettingsCloudInfo =>
      'Локальні параметри продуктивності приховані, поки активний хмарний ШІ.';
}
