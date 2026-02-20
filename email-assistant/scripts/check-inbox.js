#!/usr/bin/env node
/**
 * Email Inbox Checker
 * Fetches unread emails, categorizes them, and notifies via Clawdbot
 */

const Imap = require('imap');
const { simpleParser } = require('mailparser');
const fs = require('fs');
const path = require('path');

// Load config
const configPath = path.join(__dirname, '../config/settings.json');
const config = fs.existsSync(configPath) 
  ? JSON.parse(fs.readFileSync(configPath, 'utf8'))
  : {};

// Email categories and keywords
const CATEGORIES = {
  urgent: ['urgent', 'asap', 'deadline', 'important', 'critical', 'emergency', 'immediately'],
  client: ['inquiry', 'quote', 'booking', 'interested', 'pricing', 'services', 'consultation', 'hire'],
  admin: ['receipt', 'invoice', 'notification', 'automated', 'noreply', 'confirmation', 'subscription'],
  spam: ['unsubscribe', 'newsletter', 'promo', 'sale', 'discount', 'limited time']
};

/**
 * Categorize email based on subject and content
 */
function categorizeEmail(email) {
  const text = `${email.subject} ${email.text || ''}`.toLowerCase();
  
  for (const [category, keywords] of Object.entries(CATEGORIES)) {
    if (keywords.some(kw => text.includes(kw))) {
      return category;
    }
  }
  return 'general';
}

/**
 * Get priority score (higher = more important)
 */
function getPriority(email, category) {
  let score = 0;
  
  if (category === 'urgent') score += 100;
  if (category === 'client') score += 50;
  if (category === 'general') score += 25;
  if (category === 'admin') score += 10;
  if (category === 'spam') score -= 50;
  
  // Boost for known contacts (would check CRM)
  // Boost for recent threads
  // Boost for short emails (usually need response)
  if ((email.text || '').length < 500) score += 10;
  
  return score;
}

/**
 * Format email for notification
 */
function formatEmailNotification(email, category) {
  const priorityEmoji = {
    urgent: '🔴',
    client: '🟢',
    general: '🔵',
    admin: '⚪',
    spam: '🟤'
  };
  
  const emoji = priorityEmoji[category] || '📧';
  const from = email.from?.text || 'Unknown';
  const subject = email.subject || '(no subject)';
  const preview = (email.text || '').substring(0, 200).replace(/\n/g, ' ');
  
  return {
    emoji,
    category,
    from,
    subject,
    preview: preview.length >= 200 ? preview + '...' : preview,
    date: email.date,
    messageId: email.messageId
  };
}

/**
 * Connect to Gmail and fetch unread emails
 */
async function checkInbox() {
  const email = process.env.GMAIL_EMAIL || config.email;
  const password = process.env.GMAIL_APP_PASSWORD || config.appPassword;
  
  if (!email || !password) {
    console.error('Error: Gmail credentials not configured');
    console.error('Set GMAIL_EMAIL and GMAIL_APP_PASSWORD environment variables');
    console.error('Or configure in config/settings.json');
    process.exit(1);
  }
  
  const imap = new Imap({
    user: email,
    password: password,
    host: 'imap.gmail.com',
    port: 993,
    tls: true,
    tlsOptions: { rejectUnauthorized: false }
  });
  
  return new Promise((resolve, reject) => {
    const emails = [];
    
    imap.once('ready', () => {
      imap.openBox('INBOX', false, (err, box) => {
        if (err) return reject(err);
        
        // Search for unread emails
        imap.search(['UNSEEN'], (err, results) => {
          if (err) return reject(err);
          
          if (!results || results.length === 0) {
            console.log('No new emails');
            imap.end();
            return resolve([]);
          }
          
          console.log(`Found ${results.length} unread email(s)`);
          
          const fetch = imap.fetch(results, { bodies: '' });
          
          fetch.on('message', (msg, seqno) => {
            msg.on('body', (stream) => {
              simpleParser(stream, (err, parsed) => {
                if (err) return console.error('Parse error:', err);
                
                const category = categorizeEmail(parsed);
                const priority = getPriority(parsed, category);
                const formatted = formatEmailNotification(parsed, category);
                
                emails.push({
                  ...formatted,
                  priority,
                  seqno
                });
              });
            });
          });
          
          fetch.once('end', () => {
            imap.end();
          });
        });
      });
    });
    
    imap.once('error', reject);
    imap.once('end', () => {
      // Sort by priority
      emails.sort((a, b) => b.priority - a.priority);
      resolve(emails);
    });
    
    imap.connect();
  });
}

/**
 * Output for Clawdbot to process
 */
async function main() {
  try {
    const emails = await checkInbox();
    
    if (emails.length === 0) {
      console.log(JSON.stringify({ status: 'ok', count: 0, emails: [] }));
      return;
    }
    
    // Output as JSON for Clawdbot to parse
    const output = {
      status: 'ok',
      count: emails.length,
      emails: emails.map(e => ({
        emoji: e.emoji,
        category: e.category,
        from: e.from,
        subject: e.subject,
        preview: e.preview,
        priority: e.priority
      }))
    };
    
    console.log(JSON.stringify(output, null, 2));
    
    // Also output human-readable summary
    console.error('\n--- Email Summary ---');
    for (const email of emails) {
      console.error(`${email.emoji} [${email.category.toUpperCase()}] ${email.from}`);
      console.error(`   ${email.subject}`);
    }
    
  } catch (error) {
    console.error('Error checking inbox:', error.message);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = { checkInbox, categorizeEmail };
