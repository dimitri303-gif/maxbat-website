# 🚀 Інструкція: Підключення «Google Таблиця + Telegram-сповіщення» для MaxBat

Ця зв'язка дозволяє:
1. **Google Таблиця:** Автоматично фіксувати кожен лід новим рядком (Дата, Ім'я, Телефон, СЦ / Місто).
2. **Telegram:** Миттєво надсилати сповіщення вам або у робочу групу менеджерів з прямим клікабельним номером телефону.
3. **Безпека:** Токен Telegram-бота надійно захований усередині Google Script і не доступний у вихідному коді сторінки.

---

## Крок 1. Створення Telegram-бота (1 хвилина)
1. Відкрийте Telegram і знайдіть офіційного бота: **@BotFather**.
2. Натисніть **Start** та відправте команду: `/newbot`.
3. Введіть назву бота (наприклад, `MaxBat Leads Bot`).
4. Введіть юзернейм бота, що закінчується на `bot` (наприклад, `maxbat_leads_bot`).
5. @BotFather надішле вам **HTTP API TOKEN** (виглядає як `7458123456:AAFlX...`). Скопіюйте його.
6. Перейдіть до свого нового бота та натисніть **Start**, щоб дозволити йому писати вам.
7. Дізнайтеся свій **CHAT_ID**: знайдіть у Telegram бота **@userinfobot** і натисніть Start (він покаже ваш числовий Id, наприклад `123456789`).

---

## Крок 2. Створення Google Таблиці (1 хвилина)
1. Створіть нову таблицю на https://sheets.new
2. Назвіть її: `MaxBat — База лідів`.
3. У першому рядку створіть заголовки:
   - **A1:** `Дата та час`
   - **B1:** `Ім'я`
   - **C1:** `Телефон / Telegram`
   - **D1:** `Назва СЦ / Місто`
   - **E1:** `Статус`

---

## Крок 3. Додавання Google Apps Script (1 хвилина)
1. У верхньому меню таблиці відкрийте: **Розширення (Extensions) -> Apps Script**.
2. Видаліть увесь стандартний код і вставте готовий скрипт:

```javascript
// НАЛАШТУВАННЯ ТЕЛЕГРАМ (Вкажіть свої дані):
const TELEGRAM_BOT_TOKEN = "ВАШ_ТОКЕН_ВІД_BOTFATHER";
const TELEGRAM_CHAT_ID = "ВАШ_CHAT_ID";

function doPost(e) {
  try {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    let data;
    
    if (e.postData && e.postData.contents) {
      data = JSON.parse(e.postData.contents);
    } else {
      data = e.parameter;
    }

    const name = data.name || "Не вказано";
    const phone = data.phone || "Не вказано";
    const company = data.company || "Не вказано";
    const timestamp = Utilities.formatDate(new Date(), "Europe/Kyiv", "dd.MM.yyyy HH:mm:ss");

    // Очищений телефон для Telegram (без лапки)
    const cleanPhone = phone.replace(/^'/, '');
    // Безпечний телефон для Таблиці (з лапкою, щоб не було #ERROR!)
    const safePhone = phone.startsWith("'") ? phone : "'" + phone;

    // 1. Вставка нового ліда ЗВЕРХУ (відразу під заголовками, рядок 2)
    sheet.insertRowAfter(1);
    sheet.getRange(2, 1, 1, 5).setValues([[timestamp, name, safePhone, company, "Новий лід"]]);

    // 2. Відправка сповіщення в Telegram
    if (TELEGRAM_BOT_TOKEN && TELEGRAM_BOT_TOKEN !== "ВАШ_ТОКЕН_ВІД_BOTFATHER") {
      const message = "🔥 *НОВА ЗАЯВКА НА ПАРТНЕРСТВО MAXBAT!*\n\n" +
                      "👤 *Ім'я:* " + name + "\n" +
                      "📞 *Телефон:* `" + cleanPhone + "`\n" +
                      "🏢 *Сервісний центр / Місто:* " + company + "\n" +
                      "🕒 *Час:* " + timestamp;

      const telegramUrl = "https://api.telegram.org/bot" + TELEGRAM_BOT_TOKEN + "/sendMessage";
      UrlFetchApp.fetch(telegramUrl, {
        method: "post",
        contentType: "application/json",
        payload: JSON.stringify({
          chat_id: TELEGRAM_CHAT_ID,
          text: message,
          parse_mode: "Markdown"
        }),
        muteHttpExceptions: true
      });
    }

    return ContentService.createTextOutput(JSON.stringify({ status: "success" }))
      .setMimeType(ContentService.MimeType.JSON);

  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({ status: "error", message: error.toString() }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
```

3. Вставте свої `TELEGRAM_BOT_TOKEN` та `TELEGRAM_CHAT_ID`.
4. Збережіть (Save).

---

## Крок 4. Розгортання Веб-додатка (1 хвилина)
1. Натисніть синю кнопку **Deploy -> New deployment** (Розгорнути -> Нове розгортання).
2. Натисніть шестірню ⚙️ -> виберіть **Web app** (Веб-додаток).
3. Налаштування:
   - **Description:** `MaxBat Leads Webhook`
   - **Execute as:** `Me` (Мій акаунт)
   - **Who has access:** `Anyone` (Усі)
4. Натисніть **Deploy**. Надайте дозволи акаунту (Authorize access -> Advanced -> Go to Untitled project -> Allow).
5. Скопіюйте отриманий **Web app URL** (закінчується на `/exec`).

---

## Крок 5. Підключення до сайту
У файлі `сайт/maxbet.ua/index.html` вставте посилання у рядок:
```javascript
const GOOGLE_SCRIPT_URL = 'https://script.google.com/macros/s/.../exec';
```
Або просто надішліть цей URL мені в чат, і я сам підключу його в код!
