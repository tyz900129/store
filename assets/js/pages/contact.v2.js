// pages/contact.js
import { toast } from '../ui.v2.js';

const form = document.getElementById('contactForm');
if (form) form.addEventListener('submit', (e) => {
  e.preventDefault();
  const fd = new FormData(form);
  if (!fd.get('email') || !fd.get('message')) {
    toast('Please fill in your email and message.', 'error');
    return;
  }
  // 实际可通过 fetch('/store/api/contact.jsp') 提交
  toast('Message sent. We will get back to you within 24h.', 'success');
  form.reset();
});
