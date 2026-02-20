#!/usr/bin/env node
/**
 * Email Reply Drafter
 * Generates AI-powered reply drafts based on email content and templates
 */

const fs = require('fs');
const path = require('path');

// Template directory
const templatesDir = path.join(__dirname, '../templates');

/**
 * Load a template by name
 */
function loadTemplate(name) {
  const templatePath = path.join(templatesDir, `${name}.md`);
  if (fs.existsSync(templatePath)) {
    return fs.readFileSync(templatePath, 'utf8');
  }
  return null;
}

/**
 * Detect reply type based on email content
 */
function detectReplyType(email) {
  const text = `${email.subject || ''} ${email.body || ''}`.toLowerCase();
  
  if (text.includes('quote') || text.includes('pricing') || text.includes('cost')) {
    return 'inquiry-response';
  }
  if (text.includes('meeting') || text.includes('schedule') || text.includes('call')) {
    return 'meeting-confirm';
  }
  if (text.includes('thank') || text.includes('received')) {
    return 'acknowledgment';
  }
  if (text.includes('question') || text.includes('help') || text.includes('support')) {
    return 'support-response';
  }
  
  return 'general';
}

/**
 * Generate reply context for AI
 */
function buildReplyContext(email, replyType) {
  return {
    originalFrom: email.from,
    originalSubject: email.subject,
    originalBody: email.body,
    replyType,
    senderFirstName: extractFirstName(email.from),
    timestamp: new Date().toISOString(),
    businessName: process.env.BUSINESS_NAME || 'our team',
    businessEmail: process.env.GMAIL_EMAIL || ''
  };
}

/**
 * Extract first name from email address or name
 */
function extractFirstName(from) {
  if (!from) return 'there';
  
  // Try to get name part before email
  const nameMatch = from.match(/^([^<]+)/);
  if (nameMatch) {
    const fullName = nameMatch[1].trim();
    return fullName.split(' ')[0];
  }
  
  // Extract from email username
  const emailMatch = from.match(/([^@]+)@/);
  if (emailMatch) {
    const username = emailMatch[1];
    // Capitalize first letter
    return username.charAt(0).toUpperCase() + username.slice(1).split(/[._]/)[0];
  }
  
  return 'there';
}

/**
 * Generate draft reply prompt for AI
 */
function generateDraftPrompt(context) {
  const { originalFrom, originalSubject, originalBody, replyType, senderFirstName, businessName } = context;
  
  const prompts = {
    'inquiry-response': `
Draft a professional, friendly reply to this business inquiry.
Be helpful and encourage next steps (call, meeting, more info).

From: ${originalFrom}
Subject: ${originalSubject}
Message: ${originalBody}

Requirements:
- Address them as "${senderFirstName}"
- Be warm but professional
- Acknowledge their specific inquiry
- Offer to schedule a call or provide more details
- Sign off as "${businessName}"
- Keep it concise (3-4 paragraphs max)
`,
    'meeting-confirm': `
Draft a meeting confirmation/scheduling reply.

From: ${originalFrom}
Subject: ${originalSubject}
Message: ${originalBody}

Requirements:
- Confirm availability or suggest alternatives
- Include any prep details if relevant
- Be concise and clear
- Sign off professionally
`,
    'support-response': `
Draft a helpful support response.

From: ${originalFrom}
Subject: ${originalSubject}
Message: ${originalBody}

Requirements:
- Acknowledge their question/issue
- Provide clear, helpful information
- Offer further assistance if needed
- Professional and empathetic tone
`,
    'general': `
Draft a professional reply to this email.

From: ${originalFrom}
Subject: ${originalSubject}
Message: ${originalBody}

Requirements:
- Match the tone of the original email
- Be helpful and clear
- Keep it appropriately brief
- Professional sign-off
`
  };
  
  return prompts[replyType] || prompts['general'];
}

/**
 * Generate default draft (without AI - template-based)
 */
function generateTemplateDraft(context) {
  const { replyType, senderFirstName, originalSubject, businessName } = context;
  
  const templates = {
    'inquiry-response': `Hi ${senderFirstName},

Thanks for reaching out! I'd be happy to discuss this further.

Could you let me know a good time for a quick call? I'm generally available [suggest times].

Alternatively, feel free to share any additional details about what you're looking for, and I'll put together some options for you.

Looking forward to connecting!

Best,
${businessName}`,

    'meeting-confirm': `Hi ${senderFirstName},

Thanks for suggesting a meeting!

I'm available at [suggest times]. Let me know what works best for you.

Talk soon,
${businessName}`,

    'support-response': `Hi ${senderFirstName},

Thanks for getting in touch.

[Address their question/issue here]

Let me know if you have any other questions!

Best,
${businessName}`,

    'general': `Hi ${senderFirstName},

Thanks for your email.

[Your response here]

Best,
${businessName}`
  };
  
  return {
    subject: originalSubject.startsWith('Re:') ? originalSubject : `Re: ${originalSubject}`,
    body: templates[replyType] || templates['general'],
    type: replyType,
    needsAI: true // Flag that this should be enhanced by AI
  };
}

/**
 * Main draft generation
 */
async function draftReply(email) {
  const replyType = detectReplyType(email);
  const context = buildReplyContext(email, replyType);
  
  // Try to load custom template first
  const customTemplate = loadTemplate(replyType);
  if (customTemplate) {
    // Replace placeholders in template
    let body = customTemplate
      .replace(/\{\{firstName\}\}/g, context.senderFirstName)
      .replace(/\{\{businessName\}\}/g, context.businessName)
      .replace(/\{\{subject\}\}/g, context.originalSubject);
    
    return {
      subject: `Re: ${email.subject}`,
      body,
      type: replyType,
      needsAI: false
    };
  }
  
  // Fall back to generated template
  const draft = generateTemplateDraft(context);
  
  // Also output the AI prompt for enhancement
  draft.aiPrompt = generateDraftPrompt(context);
  
  return draft;
}

/**
 * CLI interface
 */
async function main() {
  // Read email from stdin or args
  let emailData;
  
  if (process.argv[2]) {
    // JSON passed as argument
    emailData = JSON.parse(process.argv[2]);
  } else {
    // Read from stdin
    const stdin = fs.readFileSync(0, 'utf8');
    emailData = JSON.parse(stdin);
  }
  
  const draft = await draftReply(emailData);
  console.log(JSON.stringify(draft, null, 2));
}

if (require.main === module) {
  main().catch(console.error);
}

module.exports = { draftReply, detectReplyType };
