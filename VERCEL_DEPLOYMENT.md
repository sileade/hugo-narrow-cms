# 🚀 Vercel Deployment Guide

## Автоматическое развертывание (Рекомендуется)

### Вариант 1: Deploy Button (1 клик)

Нажмите кнопку ниже для автоматического развертывания:

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/sileade/hugo-narrow-cms)

**Что произойдет:**
1. Vercel создаст fork репозитория
2. Автоматически настроит проект
3. Развернет сайт
4. Предоставит URL (например: `hugo-narrow-cms.vercel.app`)

**Время:** ~2 минуты

---

### Вариант 2: Через GitHub Integration

1. Перейдите на https://vercel.com/new
2. Войдите через GitHub
3. Выберите репозиторий `sileade/hugo-narrow-cms`
4. Нажмите "Import"
5. Настройки определятся автоматически из `vercel.json`
6. Нажмите "Deploy"

**Настройки (автоматические):**
```json
{
  "buildCommand": "hugo --minify",
  "outputDirectory": "public",
  "framework": "hugo",
  "installCommand": "wget -q https://github.com/gohugoio/hugo/releases/download/v0.146.0/hugo_extended_0.146.0_Linux-64bit.tar.gz && tar -xzf hugo_extended_0.146.0_Linux-64bit.tar.gz && chmod +x hugo && mv hugo /usr/local/bin/"
}
```

---

### Вариант 3: Vercel CLI

```bash
# 1. Установить Vercel CLI
npm install -g vercel

# 2. Войти в Vercel
vercel login

# 3. Развернуть проект
cd hugo-narrow-cms
vercel

# 4. Для production деплоя
vercel --prod
```

---

## Настройка после развертывания

### 1. Настроить домен (опционально)

**В Vercel Dashboard:**
1. Откройте проект
2. Settings → Domains
3. Добавьте свой домен
4. Настройте DNS записи

**Пример DNS:**
```
Type: A
Name: @
Value: 76.76.21.21

Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

---

### 2. Настроить переменные окружения

**Для админ-панели (GitHub OAuth):**

1. Settings → Environment Variables
2. Добавьте:
   - `GITHUB_TOKEN` - ваш GitHub токен
   - `GITHUB_REPO` - `sileade/hugo-narrow-cms`

---

### 3. Включить автоматический деплой

**По умолчанию включено:**
- ✅ Push в `main` → Production deploy
- ✅ Push в другие ветки → Preview deploy
- ✅ Pull Request → Preview deploy

**Отключить (если нужно):**
1. Settings → Git
2. Снять галочку "Production Branch"

---

## Проверка развертывания

После деплоя проверьте:

### ✅ Чеклист

- [ ] Сайт открывается по URL
- [ ] Все страницы загружаются
- [ ] Стили применяются корректно
- [ ] Изображения отображаются
- [ ] Админ-панель доступна по `/admin/`
- [ ] Темная тема работает
- [ ] Мобильная версия корректна
- [ ] SSL сертификат активен (https://)

### 🧪 Тестовые URL

```
https://your-project.vercel.app/
https://your-project.vercel.app/posts/
https://your-project.vercel.app/about/
https://your-project.vercel.app/contact/
https://your-project.vercel.app/admin/
```

---

## Автоматизация

### GitHub Actions (уже настроен)

Файл `.github/workflows/deploy.yml` автоматически деплоит на Vercel при push в main.

**Что происходит:**
1. Push в `main`
2. GitHub Actions запускает workflow
3. Hugo собирает сайт
4. Vercel деплоит на production
5. Сайт обновляется (~2-3 минуты)

---

## Мониторинг

### Vercel Dashboard

**Доступно:**
- 📊 Analytics (посещения, страны, устройства)
- ⚡ Performance metrics (Core Web Vitals)
- 🐛 Error tracking
- 📝 Deployment logs
- 🔄 Rollback к предыдущим версиям

**URL:** https://vercel.com/dashboard

---

## Troubleshooting

### Проблема: Build failed

**Решение:**
```bash
# Проверить локально
hugo --minify

# Проверить логи в Vercel
# Dashboard → Deployments → [Failed deployment] → View logs
```

### Проблема: 404 на страницах

**Решение:**
Проверьте `vercel.json`:
```json
{
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/$1"
    }
  ]
}
```

### Проблема: Админ-панель не работает

**Решение:**
1. Проверьте `static/admin/config.yml`
2. Настройте GitHub OAuth
3. Добавьте переменные окружения в Vercel

---

## Стоимость

### Free Plan (достаточно для большинства)

- ✅ 100 GB bandwidth/месяц
- ✅ Unlimited deployments
- ✅ Automatic SSL
- ✅ Global CDN
- ✅ Serverless Functions (100 GB-hours)
- ✅ 1 concurrent build

### Pro Plan ($20/месяц)

- ✅ 1 TB bandwidth
- ✅ Advanced analytics
- ✅ Password protection
- ✅ 12 concurrent builds
- ✅ Priority support

**Для блога Free Plan более чем достаточно!**

---

## Альтернативы Vercel

### Netlify

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --prod
```

**Deploy Button:**
[![Deploy to Netlify](https://www.netlify.com/img/deploy/button.svg)](https://app.netlify.com/start/deploy?repository=https://github.com/sileade/hugo-narrow-cms)

### Cloudflare Pages

1. https://pages.cloudflare.com/
2. Connect GitHub
3. Select repository
4. Build command: `hugo --minify`
5. Output: `public`

### GitHub Pages

```yaml
# .github/workflows/pages.yml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: '0.146.0'
          extended: true
      - name: Build
        run: hugo --minify
      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
```

---

## Полезные ссылки

- 📚 Vercel Docs: https://vercel.com/docs
- 🎓 Hugo Deployment: https://gohugo.io/hosting-and-deployment/
- 🔧 Vercel CLI: https://vercel.com/docs/cli
- 💬 Support: https://vercel.com/support

---

## Резюме

### Быстрый старт (30 секунд)

1. Нажмите: [![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/sileade/hugo-narrow-cms)
2. Войдите через GitHub
3. Нажмите "Deploy"
4. Готово! 🎉

**Ваш сайт будет доступен по адресу:**
`https://hugo-narrow-cms-[random].vercel.app`

**Админ-панель:**
`https://hugo-narrow-cms-[random].vercel.app/admin/`

---

<div align="center">

**🚀 Развертывание на Vercel - самый простой способ!**

**2 минуты • Бесплатно • Автоматический SSL • Глобальный CDN**

</div>
