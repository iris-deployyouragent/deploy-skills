#!/usr/bin/env node
/**
 * Email Sender
 * Sends approved email drafts via Gmail
 */

const nodemailer = require('nodemailer');
const fs = require('fs');
const path = require('path');

// Load config
const configPath = path.join(__dirname, '../config/settings.json');
const config = fs.existsSync(configPath) 
  ? JSON.parse(fs.readFileSync(configPath, 'utf8'))
  : {};

/**
 * Create Gmail transporter
 */
function createTransporter() {
  const email = process.env.GMAIL_EMAIL || config.email;
  const password = process.env.GMAIL_APP_PASSWORD || config.appPassword;
  
  if (!email || !password) {
    throw new Error('Gmail credentials not configured. Set GMAIL_EMAIL and GMAIL_APP_PASSWORD.');
  }
  
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: email,
      pass: password
    }
  });
}

/**
 * Send an email
 */
async function sendEmail(options) {
  const { to, subject, body, replyTo, cc, bcc, attachments } = options;
  
  const transporter = createTransporter();
  const from = process.env.GMAIL_EMAIL || config.email;
  
  const mailOptions = {
    from,
    to,
    subject,
    text: body,
    // Also send HTML version
    html: body.replace(/\n/g, '<br>'),
    replyTo: replyTo || from,
    cc,
    bcc,
    attachments
  };
  
  try {
    const result = await transporter.sendMail(mailOptions);
    return {
      success: true,
      messageId: result.messageId,
      to,
      subject
    };
  } catch (error) {
    return {
      success: false,
      error: error.message,
      to,
      subject
    };
  }
}

/**
 * Send a reply (includes In-Reply-To header)
 */
async function sendReply(options) {
  const { to, subject, body, originalMessageId, threadId } = options;
  
  const transporter = createTransporter();
  const from = process.env.GMAIL_EMAIL || config.email;
  
  const mailOptions = {
    from,
    to,
    subject: subject.startsWith('Re:') ? subject : `Re: ${subject}`,
    text: body,
    html: body.replace(/\n/g, '<br>'),
    headers: {}
  };
  
  // Add threading headers if available
  if (originalMessageId) {
    mailOptions.headers['In-Reply-To'] = originalMessageId;
    mailOptions.headers['References'] = originalMessageId;
  }
  
  try {
    const result = await transporter.sendMail(mailOptions);
    return {
      success: true,
      messageId: result.messageId,
      to,
      subject: mailOptions.subject,
      isReply: true
    };
  } catch (error) {
    return {
      success: false,
      error: error.message,
      to,
      subject
    };
  }
}

/**
 * Verify Gmail connection
 */
async function verifyConnection() {
  try {
    const transporter = createTransporter();
    await transporter.verify();
    return { success: true, message: 'Gmail connection verified' };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

/**
 * CLI interface
 */
async function main() {
  const command = process.argv[2];
  
  if (command === 'verify') {
    const result = await verifyConnection();
    console.log(JSON.stringify(result, null, 2));
    process.exit(result.success ? 0 : 1);
  }
  
  if (command === 'send') {
    // Read email data from stdin or argument
    let emailData;
    if (process.argv[3]) {
      emailData = JSON.parse(process.argv[3]);
    } else {
      const stdin = fs.readFileSync(0, 'utf8');
      emailData = JSON.parse(stdin);
    }
    
    const result = emailData.isReply 
      ? await sendReply(emailData)
      : await sendEmail(emailData);
    
    console.log(JSON.stringify(result, null, 2));
    process.exit(result.success ? 0 : 1);
  }
  
  // Help
  console.log(`
Email Sender - Usage:

  verify              Test Gmail connection
  send [json]         Send email (JSON from stdin or argument)

Email JSON format:
{
  "to": "recipient@example.com",
  "subject": "Subject line",
  "body": "Email body text",
  "isReply": false,
  "originalMessageId": "<optional-for-replies>"
}

Environment variables:
  GMAIL_EMAIL         Your Gmail address
  GMAIL_APP_PASSWORD  Gmail app password
`);
}

if (require.main === module) {
  main().catch(console.error);
}

module.exports = { sendEmail, sendReply, verifyConnection };
