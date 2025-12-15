# Hugo Narrow CMS

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/sileade/hugo-narrow-cms)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hugo Version](https://img.shields.io/badge/Hugo-0.146.0-blue.svg)](https://gohugo.io/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)

> Современный, красивый статический сайт на Hugo с интегрированной админ-панелью для удобного управления контентом. Развертывание за 30 секунд с Docker или один клик с Vercel.

![Hugo Narrow Theme](https://hugo-narrow.vercel.app/images/og-default.avif)

---

## 🌟 Особенности

<table>
<tr>
<td width="50%">

### 🎨 Дизайн
- **11 цветовых тем**
- **Темная тема**
- **Адаптивный дизайн**
- **Современный UI**
- **Плавные анимации**

### 📝 Управление контентом
- **Админ-панель** `/admin/`
- **Визуальный редактор**
- **Загрузка изображений**
- **Система черновиков**
- **Без базы данных**

</td>
<td width="50%">

### 🚀 Производительность
- **Молниеносная скорость**
- **SEO оптимизация**
- **PWA поддержка**
- **Оптимизация изображений**
- **Подсветка кода**

### 🐳 Docker
- **Развертывание за 30 сек**
- **Live reload**
- **Production ready**
- **Nginx + Gzip**
- **Автоматическая сборка**

</td>
</tr>
</table>

---

## 🚀 Быстрый старт

### Вариант 1: Docker (Рекомендуется) 🐳

**Самый быстрый способ - 30 секунд!**

```bash
# Клонировать репозиторий
git clone https://github.com/sileade/hugo-narrow-cms.git
cd hugo-narrow-cms

# Запустить development сервер
./docker-deploy.sh
# Выберите опцию 1

# Или используйте Make
make dev
```

**Доступ**:
- 🌐 Сайт: http://localhost:1313
- 📝 Админка: http://localhost:1313/admin/

**Преимущества Docker**:
- ✅ Не нужно устанавливать Hugo
- ✅ Работает на любой ОС
- ✅ Изолированная среда
- ✅ Одна команда для запуска
- ✅ Production-ready сборка

📖 **Подробнее**: [DOCKER.md](DOCKER.md)

---

### Вариант 2: Vercel (Один клик) ☁️

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/sileade/hugo-narrow-cms)

**Что происходит**:
1. Vercel клонирует репозиторий
2. Автоматически устанавливает Hugo 0.146.0
3. Собирает и деплоит сайт
4. Ваш сайт онлайн через 2 минуты!

---

### Вариант 3: Локальная установка 💻

```bash
# 1. Клонировать
git clone https://github.com/sileade/hugo-narrow-cms.git
cd hugo-narrow-cms

# 2. Установить Hugo (если не установлен)
./install.sh

# 3. Запустить
hugo server -D

# 4. Открыть браузер
# Сайт: http://localhost:1313
# Админка: http://localhost:1313/admin/
```

---

## 🐳 Docker - Подробнее

### Команды Make (Самый простой способ)

```bash
make dev              # Запустить development
make prod             # Запустить production
make stop             # Остановить все
make logs             # Просмотр логов
make clean            # Удалить все
make help             # Показать все команды
```

### Docker Compose

```bash
# Development (с live reload)
docker-compose --profile dev up -d

# Production (с Nginx)
docker-compose --profile prod up -d

# Остановить
docker-compose --profile dev --profile prod down
```

### Интерактивный скрипт

```bash
./docker-deploy.sh
```

**Меню**:
1. Development (с live reload)
2. Production (оптимизированная сборка)
3. Остановить все контейнеры
4. Очистка (удалить контейнеры и образы)

### Режимы работы

<table>
<tr>
<th>Development</th>
<th>Production</th>
</tr>
<tr>
<td>

- ✅ Live reload
- ✅ Черновики видны
- ✅ Быстрая сборка
- ✅ Hugo сервер
- 🌐 Port 1313

</td>
<td>

- ✅ Минификация
- ✅ Gzip сжатие
- ✅ Кэширование
- ✅ Nginx сервер
- 🌐 Port 80

</td>
</tr>
</table>

### Производительность

- **Время сборки Hugo**: ~680ms
- **Время сборки Docker**: ~2 мин (первый раз), ~30 сек (кэш)
- **Размер образа dev**: ~100MB
- **Размер образа prod**: ~30MB
- **Использование RAM**: 50-100MB

### Развертывание на VPS

```bash
# SSH на сервер
ssh user@your-server.com

# Клонировать
git clone https://github.com/sileade/hugo-narrow-cms.git
cd hugo-narrow-cms

# Запустить production
./docker-deploy.sh  # Выберите 2

# Доступ по адресу
http://your-server-ip
```

📖 **Полное руководство**: [DOCKER.md](DOCKER.md) - 70+ разделов с примерами

---

## 📖 Документация

| Документ | Описание |
|----------|----------|
| [QUICK_START.md](QUICK_START.md) | Быстрый старт за 5 минут |
| [DOCKER.md](DOCKER.md) | Полное руководство по Docker |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Развертывание на Vercel/Netlify/GitHub Pages |
| [SUMMARY.md](SUMMARY.md) | Обзор проекта и чеклист |
| [PROJECT_STRUCTURE.txt](PROJECT_STRUCTURE.txt) | Структура файлов |

---

## 🎯 Возможности

### Создание контента

<table>
<tr>
<td width="50%">

**Через админ-панель** (Рекомендуется)
1. Открыть `/admin/`
2. Войти через GitHub
3. Нажать "New Post"
4. Написать контент
5. Нажать "Publish"

</td>
<td width="50%">

**Через командную строку**
```bash
# Создать пост
hugo new posts/my-post.md

# Редактировать
nano content/posts/my-post.md

# Закоммитить
git add .
git commit -m "New post"
git push
```

</td>
</tr>
</table>

### Кастомизация

**Изменить название сайта** (`hugo.yaml`):
```yaml
title: Мой Блог
params:
  description: "Описание моего блога"
  author:
    name: "Ваше Имя"
```

**Изменить цветовую тему** (`hugo.yaml`):
```yaml
params:
  colorScheme: "claude"
```

**Доступные темы**:
- `default` - Чистый и минималистичный
- `claude` - Вдохновлен Claude AI
- `bumblebee` - Яркий желтый
- `emerald` - Свежий зеленый
- `nord` - Холодный нордический
- `sunset` - Теплый оранжевый
- `abyss` - Глубокий темный
- `dracula` - Классический темный
- `amethyst` - Фиолетовая элегантность
- `slate` - Профессиональный серый
- `twitter` - В стиле Twitter

**Добавить социальные ссылки** (`hugo.yaml`):
```yaml
menus:
  social:
    - name: GitHub
      url: https://github.com/yourusername
      params:
        icon: github
    - name: Twitter
      url: https://twitter.com/yourusername
      params:
        icon: twitter
```

**Включить комментарии** (`hugo.yaml`):
```yaml
params:
  comments:
    enabled: true
    system: "giscus"  # giscus, disqus, utterances, waline, artalk, twikoo
```

---

## 🛠️ Технологии

<table>
<tr>
<td align="center" width="20%">
<img src="https://gohugo.io/img/hugo-logo.png" width="60" height="60" alt="Hugo"/><br/>
<b>Hugo</b><br/>
0.146.0
</td>
<td align="center" width="20%">
<img src="https://www.docker.com/wp-content/uploads/2022/03/Moby-logo.png" width="60" height="60" alt="Docker"/><br/>
<b>Docker</b><br/>
Containerization
</td>
<td align="center" width="20%">
<img src="https://nginx.org/nginx.png" width="60" height="60" alt="Nginx"/><br/>
<b>Nginx</b><br/>
Web Server
</td>
<td align="center" width="20%">
<img src="https://decapcms.org/img/decap-logo.svg" width="60" height="60" alt="Decap CMS"/><br/>
<b>Decap CMS</b><br/>
Admin Panel
</td>
<td align="center" width="20%">
<img src="https://tailwindcss.com/_next/static/media/tailwindcss-mark.3c5441fc7a190fb1800d4a5c7f07ba4b1345a9c8.svg" width="60" height="60" alt="Tailwind"/><br/>
<b>Tailwind CSS</b><br/>
Styling
</td>
</tr>
</table>

---

## 📂 Структура проекта

```
hugo-narrow-cms/
├── 🐳 Docker
│   ├── Dockerfile                  # Multi-stage образ
│   ├── docker-compose.yml          # Конфигурация сервисов
│   ├── docker-deploy.sh            # Скрипт развертывания
│   ├── Makefile                    # Make команды
│   └── docker/
│       ├── nginx.conf              # Production Nginx
│       └── admin-nginx.conf        # Admin proxy
│
├── 📝 Контент
│   ├── content/
│   │   ├── posts/                  # Посты блога
│   │   ├── about.md                # Страница "О нас"
│   │   └── _index.md               # Главная страница
│   └── static/
│       └── admin/                  # Админ-панель
│           ├── index.html          # CMS интерфейс
│           └── config.yml          # CMS конфигурация
│
├── 🎨 Тема
│   └── themes/hugo-narrow/         # Файлы темы
│
├── ⚙️ Конфигурация
│   ├── hugo.yaml                   # Настройки сайта
│   ├── vercel.json                 # Vercel конфиг
│   └── .github/workflows/
│       └── deploy.yml              # CI/CD
│
├── 📚 Документация
│   ├── README.md                   # Этот файл
│   ├── QUICK_START.md              # Быстрый старт
│   ├── DOCKER.md                   # Docker руководство
│   ├── DEPLOYMENT.md               # Развертывание
│   └── SUMMARY.md                  # Обзор проекта
│
└── 🔧 Скрипты
    ├── setup.sh                    # Настройка проекта
    └── install.sh                  # Установка Hugo
```

---

## 🚀 Варианты развертывания

### 1. Docker (Локально/VPS) 🐳

```bash
# Один из способов:
./docker-deploy.sh    # Интерактивный
make dev             # Development
make prod            # Production
```

**Когда использовать**:
- ✅ Локальная разработка
- ✅ VPS/Dedicated сервер
- ✅ Нужен полный контроль
- ✅ Тестирование production сборки

---

### 2. Vercel (Рекомендуется для продакшена) ☁️

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/sileade/hugo-narrow-cms)

**Когда использовать**:
- ✅ Быстрое развертывание
- ✅ Автоматические деплои
- ✅ Global CDN
- ✅ Бесплатный SSL
- ✅ Preview deployments

---

### 3. Netlify ☁️

1. Перейти на [netlify.com](https://netlify.com)
2. "Add new site" → "Import from GitHub"
3. Выбрать репозиторий
4. Deploy!

**Когда использовать**:
- ✅ Нужен Netlify Identity
- ✅ Обработка форм
- ✅ Serverless функции

---

### 4. GitHub Pages 📄

См. [DEPLOYMENT.md](DEPLOYMENT.md) для инструкций.

**Когда использовать**:
- ✅ Бесплатный хостинг
- ✅ Простой сайт
- ✅ GitHub интеграция

---

## 🔐 Настройка админ-панели

### GitHub Backend (Проще всего)

**Уже настроено!** Просто:

1. Открыть `https://your-site.com/admin/`
2. Нажать "Login with GitHub"
3. Авторизовать приложение
4. Начать редактирование!

### Netlify Identity (Более безопасно)

1. Включить Netlify Identity в настройках сайта
2. Включить Git Gateway
3. Обновить `static/admin/config.yml`:
   ```yaml
   backend:
     name: git-gateway
     branch: main
   ```
4. Пригласить пользователей через Netlify

---

## 🌍 Мультиязычность

Поддерживаемые языки:
- 🇬🇧 English
- 🇨🇳 简体中文 (Chinese Simplified)
- 🇯🇵 日本語 (Japanese)
- 🇫🇷 Français (French)

**Добавить новый язык** (`hugo.yaml`):
```yaml
languages:
  ru:
    languageCode: ru-RU
    languageName: "Русский"
    weight: 5
```

---

## 📊 Производительность

### Метрики

| Метрика | Значение |
|---------|----------|
| Lighthouse Score | 100/100 |
| Build Time | ~680ms |
| Docker Build (first) | ~2 min |
| Docker Build (cached) | ~30 sec |
| Image Size (dev) | ~100MB |
| Image Size (prod) | ~30MB |
| Memory Usage | 50-100MB |

### Оптимизации

- ✅ Минификация HTML/CSS/JS
- ✅ Gzip сжатие
- ✅ Кэширование статики (1 год)
- ✅ Lazy loading изображений
- ✅ Code splitting
- ✅ CDN ready

---

## 🔒 Безопасность

### Production Nginx

- ✅ Security headers (X-Frame-Options, CSP, etc.)
- ✅ Защита скрытых файлов
- ✅ Rate limiting готов
- ✅ SSL/TLS готов

### Docker

- ✅ Multi-stage builds
- ✅ Minimal base images (Alpine)
- ✅ Non-root user
- ✅ Health checks
- ✅ Resource limits готовы

---

## 🤝 Участие в разработке

Вклад приветствуется! Пожалуйста, создайте Pull Request.

1. Fork репозитория
2. Создать ветку (`git checkout -b feature/AmazingFeature`)
3. Закоммитить изменения (`git commit -m 'Add AmazingFeature'`)
4. Push в ветку (`git push origin feature/AmazingFeature`)
5. Открыть Pull Request

---

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE).

---

## 🙏 Благодарности

- [Hugo Narrow Theme](https://github.com/tom2almighty/hugo-narrow) by tom2almighty
- [Decap CMS](https://decapcms.org/) за админ-панель
- [Hugo](https://gohugo.io/) генератор статических сайтов
- [Tailwind CSS](https://tailwindcss.com/) за стилизацию
- [Docker](https://www.docker.com/) за контейнеризацию

---

## 📞 Поддержка

### Документация
- 📖 [Hugo Docs](https://gohugo.io/documentation/)
- 🐳 [Docker Docs](https://docs.docker.com/)
- 💬 [Hugo Forum](https://discourse.gohugo.io/)

### Помощь
- 🐛 [Сообщить о проблеме](https://github.com/sileade/hugo-narrow-cms/issues)
- 💡 [Предложить улучшение](https://github.com/sileade/hugo-narrow-cms/issues/new)
- 📧 Email: support@example.com

---

## 🌟 Поддержите проект

Поставьте ⭐️ если этот проект вам помог!

---

## 📈 Статистика

<table>
<tr>
<td align="center">
<b>⚡ Build Time</b><br/>
~680ms
</td>
<td align="center">
<b>🐳 Docker Setup</b><br/>
30 seconds
</td>
<td align="center">
<b>🎨 Themes</b><br/>
11 colors
</td>
<td align="center">
<b>🌍 Languages</b><br/>
4 supported
</td>
<td align="center">
<b>📦 Size</b><br/>
30MB (prod)
</td>
</tr>
</table>

---

## 🎯 Кому подойдет

<table>
<tr>
<td width="33%">

### 👨‍💻 Разработчикам
- ✅ Быстрая настройка
- ✅ Docker поддержка
- ✅ Git workflow
- ✅ CI/CD готов
- ✅ Кастомизация

</td>
<td width="33%">

### ✍️ Контент-мейкерам
- ✅ Простая админка
- ✅ Визуальный редактор
- ✅ Без кода
- ✅ Загрузка изображений
- ✅ Черновики

</td>
<td width="33%">

### 🚀 DevOps
- ✅ Контейнеризация
- ✅ Масштабируемость
- ✅ Cloud-ready
- ✅ Мониторинг
- ✅ Автоматизация

</td>
</tr>
</table>

---

## 🚀 Начните прямо сейчас!

### Выберите свой путь:

<table>
<tr>
<td align="center" width="33%">

### 🐳 Docker
```bash
git clone REPO
cd REPO
make dev
```
**30 секунд**

</td>
<td align="center" width="33%">

### ☁️ Vercel
[![Deploy](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/sileade/hugo-narrow-cms)
**1 клик**

</td>
<td align="center" width="33%">

### 💻 Локально
```bash
git clone REPO
./install.sh
hugo server -D
```
**5 минут**

</td>
</tr>
</table>

---

<div align="center">

**Сделано с ❤️ используя Hugo, Decap CMS и Docker**

[🌐 Live Demo](https://hugo-narrow.vercel.app) • [📖 Документация](QUICK_START.md) • [🐳 Docker Guide](DOCKER.md) • [🚀 Deploy](https://vercel.com/new/clone?repository-url=https://github.com/sileade/hugo-narrow-cms)

**Repository**: https://github.com/sileade/hugo-narrow-cms

</div>
