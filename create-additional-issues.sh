#!/bin/bash
# Script to create additional GitHub issues for homelab improvements

set -e

echo "Creating additional homelab improvement issues..."

# Create labels if they don't exist
gh label create "enhancement" --description "New feature or improvement" --color "a2eeef" 2>/dev/null || echo "  - Label 'enhancement' already exists"
gh label create "automation" --description "Automation related" --color "006b75" 2>/dev/null || echo "  - Label 'automation' already exists"
gh label create "beginner-friendly" --description "Good for beginners" --color "7057ff" 2>/dev/null || echo "  - Label 'beginner-friendly' already exists"

echo ""

# Issue 1: Discord Webhook
gh issue create --title "Set up Discord webhook for GitHub notifications" --body "$(cat <<'EOF'
## Overview
Set up a Discord webhook to receive notifications about GitHub repository events (pushes, pull requests, issues, etc.). This is a great way to stay updated on changes and learn how webhooks work.

## What is a Webhook?
A webhook is a way for one application (GitHub) to send automated messages to another application (Discord) when something happens. Think of it as a notification system where GitHub "calls" Discord whenever there's an update.

## Prerequisites
- Discord account
- A Discord server where you have admin permissions (or create a new one)
- This GitHub repository

## Step-by-Step Instructions for Beginners

### Part 1: Create a Discord Webhook

1. **Open Discord** and go to your server
2. **Right-click on the channel** where you want notifications (or create a new channel like `#github-updates`)
3. Click **"Edit Channel"**
4. Go to **"Integrations"** in the left sidebar
5. Click **"Create Webhook"** (or "Webhooks" → "New Webhook")
6. **Name your webhook** (e.g., "GitHub Homelab")
7. **Copy the Webhook URL** (you'll need this soon)
   - ⚠️ Keep this URL secret! Anyone with this URL can post to your Discord channel
8. Click **"Save Changes"**

### Part 2: Add Webhook to GitHub

1. **Go to your GitHub repository** (https://github.com/Benle90/homelab-docs)
2. Click **"Settings"** (top menu)
3. Click **"Webhooks"** in the left sidebar
4. Click **"Add webhook"**
5. **Configure the webhook:**
   - **Payload URL:** Paste your Discord webhook URL and add `/github` at the end
     - Example: `https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_TOKEN/github`
     - ⚠️ The `/github` at the end is important!
   - **Content type:** Select `application/json`
   - **Which events:** Start with "Just the push event" (you can add more later)
   - **Active:** Make sure this is checked ✅
6. Click **"Add webhook"**

### Part 3: Test It!

1. Make a small change to your repository (edit README.md or any file)
2. Commit and push the change
3. Check your Discord channel - you should see a notification! 🎉

### What Events Can You Subscribe To?

Start simple, then expand:
- ✅ **Push events** (commits) - Good starting point
- 📝 **Issues** (created, closed, commented)
- 🔄 **Pull requests** (opened, merged)
- ⭐ **Stars** (someone starred your repo)
- 👀 **Releases** (new version published)

You can add more events later by editing the webhook settings.

### Learning Resources

**How Webhooks Work:**
- [GitHub Webhooks Documentation](https://docs.github.com/en/webhooks)
- [Discord Webhooks Guide](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)

**What you'll learn:**
- How webhooks enable real-time communication between services
- How to configure integrations without coding
- Event-driven architecture basics
- How to parse JSON payloads (if you want to customize later)

### Troubleshooting

**No notifications appearing?**
1. Check the webhook URL has `/github` at the end
2. Go to GitHub webhook settings and check "Recent Deliveries" tab
3. Look for green checkmarks (success) or red X's (failed)
4. Make sure the webhook is "Active"

**Too many notifications?**
- Edit the webhook and change "Which events would you like to trigger this webhook?"
- Uncheck events you don't need

### Next Steps (Optional)

Once you're comfortable with basic webhooks:
1. Create separate Discord channels for different event types
2. Set up webhooks for multiple repositories
3. Learn about webhook payloads and what information they contain
4. Explore custom webhook bots for more advanced formatting

## Success Criteria
- [ ] Discord webhook created
- [ ] GitHub webhook configured
- [ ] Test push notification received in Discord
- [ ] Understand how webhooks work
- [ ] (Optional) Customized which events to receive

## Labels
`enhancement`, `automation`, `beginner-friendly`, `documentation`

---

**Estimated time:** 15-30 minutes
**Difficulty:** Beginner
**Cost:** Free
EOF
)" --label "enhancement,automation,beginner-friendly,documentation"

echo "✅ Created Discord webhook issue"

# Issue 2: Deploy Docs Site
gh issue create --title "Deploy documentation site to Cloudflare Pages" --body "$(cat <<'EOF'
## Overview
Deploy your homelab documentation as a public (or private) website using Cloudflare Pages. This makes your docs easily accessible from anywhere and automatically updates whenever you push changes to GitHub.

## What is Cloudflare Pages?
Cloudflare Pages is a free service that hosts static websites. It automatically rebuilds and deploys your site whenever you push to GitHub - no manual uploading required!

## Why Deploy Your Docs?

**Benefits:**
- 📱 Access your documentation from any device (phone, tablet, laptop)
- 🔗 Share specific pages with family/friends via URL
- 🚀 Automatic deployments (push to GitHub → site updates automatically)
- 🆓 Free hosting with unlimited bandwidth
- 🔒 Optional password protection for sensitive pages
- ⚡ Fast global CDN (your site loads quickly anywhere in the world)

## Prerequisites
- GitHub repository with markdown docs (you already have this!)
- Cloudflare account (free)
- Basic understanding of markdown

## Step-by-Step Instructions for Beginners

### Part 1: Choose a Static Site Generator

Your docs are in Markdown. To make them into a website, you need a "static site generator." Here are beginner-friendly options:

**Recommended: MkDocs** (easiest for beginners)
- Simple configuration
- Great for documentation
- Built-in search
- Mobile-friendly themes

**Alternative: Docusaurus** (if you want something fancier)
- More features
- Used by Facebook, Stripe, etc.
- Slightly more complex

For this guide, we'll use **MkDocs** because it's simpler.

### Part 2: Set Up MkDocs Locally

1. **Install Python** (if not already installed)
   ```bash
   # Check if Python is installed
   python3 --version

   # If not installed, install it
   sudo apt update
   sudo apt install python3 python3-pip -y
   ```

2. **Install MkDocs**
   ```bash
   pip3 install mkdocs mkdocs-material
   ```

3. **Navigate to your docs directory**
   ```bash
   cd /home/bence/VS\ Code\ Projects/homelab/documentation
   ```

4. **Create MkDocs configuration**
   ```bash
   # Create a new file called mkdocs.yml
   nano mkdocs.yml
   ```

5. **Add this basic configuration** (copy and paste):
   ```yaml
   site_name: Homelab Documentation
   site_description: Personal homelab setup and procedures
   site_author: Bence

   theme:
     name: material
     palette:
       primary: indigo
       accent: indigo
     features:
       - navigation.tabs
       - navigation.sections
       - toc.integrate
       - search.suggest

   nav:
     - Home: README.md
     - Current State: current-state.md
     - Quick Reference: QUICK-REFERENCE.md
     - Servers:
       - Infrastructure: servers/infra-server.md
       - Storage: servers/storage-server.md
     - Network: network.md
     - Procedures:
       - Migration Plan: procedures/migration-plan.md
     - Recovery:
       - Backup Strategy: recovery/backup-strategy.md
       - Disaster Recovery: recovery/disaster-recovery.md
     - Changelog: CHANGELOG.md
     - Lessons Learned: LESSONS-LEARNED.md

   markdown_extensions:
     - admonition
     - codehilite
     - toc:
         permalink: true
   ```

6. **Test locally**
   ```bash
   mkdocs serve
   ```
   - Open your browser to `http://127.0.0.1:8000`
   - You should see your docs as a website! 🎉

7. **Stop the server** (press `Ctrl+C` when done testing)

### Part 3: Set Up Cloudflare Pages

1. **Create a Cloudflare account**
   - Go to [cloudflare.com](https://cloudflare.com)
   - Sign up (free account is fine)
   - Verify your email

2. **Create a new Pages project**
   - Log in to Cloudflare Dashboard
   - Click **"Pages"** in the left sidebar
   - Click **"Create a project"**
   - Click **"Connect to Git"**

3. **Connect GitHub**
   - Click **"GitHub"**
   - Authorize Cloudflare to access GitHub
   - Select your repository: `homelab-docs`

4. **Configure build settings**
   - **Project name:** `homelab-docs` (or whatever you prefer)
   - **Production branch:** `main`
   - **Framework preset:** Select "None" or "Other"
   - **Build command:** `mkdocs build`
   - **Build output directory:** `site`

5. **Add environment variables** (if needed)
   - Usually not needed for basic MkDocs

6. **Click "Save and Deploy"**

### Part 4: Wait for First Deployment

- Cloudflare will build your site (takes 1-5 minutes)
- Watch the build logs (exciting! 🚀)
- When done, you'll get a URL like: `https://homelab-docs.pages.dev`

### Part 5: Test Your Site

1. **Visit the URL** Cloudflare gave you
2. **Click around** - make sure all pages work
3. **Test on mobile** - check if it's readable

### Part 6: Set Up Automatic Deployments

Good news: It's already set up! 🎉

**How it works:**
1. You edit a markdown file locally
2. You commit and push to GitHub
3. Cloudflare detects the push (via webhook)
4. Cloudflare rebuilds and deploys your site automatically
5. Your site updates within 1-2 minutes

**Test it:**
1. Edit any markdown file (e.g., add a line to README.md)
2. Commit and push to GitHub
3. Go to Cloudflare Pages dashboard
4. Watch the deployment in progress
5. Once done, check your site - it should be updated!

### Part 7: (Optional) Share with Family

**If you want to share:**
1. Your site URL: `https://homelab-docs.pages.dev`
2. Share this with family members who want to check service status

**If you want to keep it private:**
1. Go to Cloudflare Pages settings
2. Click **"Access Policy"**
3. Enable **"Cloudflare Access"**
4. Set up authentication (email-based, Google, GitHub, etc.)
5. Now only authorized people can view the site

### Part 8: (Optional) Custom Domain

If you own a domain (like `homelab.yourdomain.com`):
1. Go to Cloudflare Pages settings
2. Click **"Custom domains"**
3. Add your domain
4. Follow DNS setup instructions
5. Wait for SSL certificate (automatic, takes 5-10 minutes)

## Troubleshooting

**Build fails?**
- Check the build logs in Cloudflare dashboard
- Make sure `mkdocs.yml` is in the root directory
- Verify all file paths in `nav:` section are correct

**Pages not showing up?**
- Check if markdown files exist at the paths specified in `mkdocs.yml`
- Make sure file names match exactly (case-sensitive)

**Site looks broken?**
- Clear your browser cache
- Check for broken links in markdown files

## Learning Resources

**MkDocs:**
- [MkDocs Getting Started](https://www.mkdocs.org/getting-started/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)

**Cloudflare Pages:**
- [Cloudflare Pages Docs](https://developers.cloudflare.com/pages/)
- [Deploy MkDocs Guide](https://developers.cloudflare.com/pages/framework-guides/deploy-an-mkdocs-site/)

**What you'll learn:**
- Static site generation
- CI/CD basics (Continuous Integration/Deployment)
- How webhooks trigger builds
- Modern web hosting architecture
- How CDNs work

## Success Criteria
- [ ] MkDocs installed and working locally
- [ ] `mkdocs.yml` configuration file created
- [ ] Site deployed to Cloudflare Pages
- [ ] Site accessible via public URL
- [ ] Automatic deployments working (test with a small change)
- [ ] (Optional) Custom domain configured
- [ ] (Optional) Access control enabled if keeping private
- [ ] (Optional) URL shared with family

## Next Steps (Optional)

Once comfortable:
1. Customize the theme colors and layout
2. Add a logo
3. Set up a custom domain
4. Add search functionality
5. Create a homepage with links to common tasks
6. Add diagrams using Mermaid
7. Set up preview deployments for branches

## Estimated Costs
- **Cloudflare Pages:** Free (unlimited bandwidth!)
- **Custom domain:** $10-15/year (optional)

---

**Estimated time:** 1-2 hours (including learning)
**Difficulty:** Beginner (with detailed instructions)
**Cost:** Free (custom domain optional)
**Recurring work:** None (automatic deployments)
EOF
)" --label "enhancement,documentation,beginner-friendly,automation"

echo "✅ Created Cloudflare Pages deployment issue"

echo ""
echo "🎉 All additional issues created successfully!"
echo ""
echo "View all issues: gh issue list"
