// pages/checkout.js
import { getCart, cartTotal, clearCart } from '../cart.v5.js';
import { money, icon, toast } from '../ui.v5.js';
import { submitOrder } from '../data.v5.js';

function render() {
  const items = getCart();
  const sub = cartTotal();
  const shipping = sub >= 80 ? 0 : 8;
  const tax = sub * 0.05;
  const total = sub + shipping + tax;

  const itemsEl = document.getElementById('orderItems');
  if (itemsEl) itemsEl.innerHTML = items.map(i => `
    <div class="summary-row" style="gap:12px;">
      <div style="width:48px;height:48px;border-radius:8px;background:var(--c-bg-warm);overflow:hidden;flex:0 0 auto;">
        <img src="${i.image}" alt="" style="width:100%;height:100%;object-fit:cover;">
      </div>
      <div style="flex:1;">
        <div style="font-size:13px;font-weight:500;">${i.title}</div>
        <div style="font-size:11px;color:var(--c-ink-3);">${i.variant ? `${i.variant.color || ''} ${i.variant.size ? '/ ' + i.variant.size : ''}` : ''} · Qty ${i.qty}</div>
      </div>
      <div style="font-weight:500;font-size:14px;">${money(i.price * i.qty)}</div>
    </div>
  `).join('') || '<p style="color:var(--c-ink-3);">No items</p>';

  const sumEl = document.getElementById('checkoutSummary');
  if (sumEl) sumEl.innerHTML = `
    <div class="summary-row"><span>Subtotal</span><span>${money(sub)}</span></div>
    <div class="summary-row"><span>Shipping</span><span>${shipping === 0 ? 'Free' : money(shipping)}</span></div>
    <div class="summary-row"><span>Tax (5%)</span><span>${money(tax)}</span></div>
    <div class="summary-row total"><span>Total</span><span>${money(total)}</span></div>
  `;

  const totalEl = document.getElementById('payTotal');
  if (totalEl) totalEl.textContent = money(total);
}

document.addEventListener('click', (e) => {
  if (e.target.closest('.pay-method label')) {
    document.querySelectorAll('.pay-method label').forEach(l => l.classList.remove('active'));
    e.target.closest('label').classList.add('active');
  }
});

const form = document.getElementById('checkoutForm');
if (form) form.addEventListener('submit', async (e) => {
  e.preventDefault();
  const fd = new FormData(form);
  const data = Object.fromEntries(fd.entries());
  if (!data.email || !data.name || !data.line1) {
    toast('Please fill required fields', 'error');
    return;
  }
  const items = getCart();
  if (items.length === 0) {
    toast('Your cart is empty', 'error');
    return;
  }
  const btn = form.querySelector('button[type="submit"]');
  btn.disabled = true;
  btn.textContent = 'Processing...';
  const sub = cartTotal();
  const shipping = sub >= 80 ? 0 : 8;
  const total = sub + shipping + sub * 0.05;
  const result = await submitOrder({
    email: data.email,
    items: items.map(i => ({ id: i.id, qty: i.qty, price: i.price })),
    address: data,
    total,
    currency: 'USD',
  });
  if (result.code === 0) {
    clearCart();
    sessionStorage.setItem('lastOrder', JSON.stringify({ id: result.orderId, total, email: data.email }));
    location.href = '/store/checkout.html?success=1&id=' + result.orderId;
  } else {
    toast('Something went wrong. Please try again.', 'error');
    btn.disabled = false;
    btn.textContent = 'Place order';
  }
});

// success view
if (new URLSearchParams(location.search).get('success') === '1') {
  const last = JSON.parse(sessionStorage.getItem('lastOrder') || '{}');
  const root = document.getElementById('checkoutRoot');
  if (root) root.innerHTML = `
    <div class="container" style="text-align:center;padding:80px 24px;max-width:560px;">
      <div style="width:80px;height:80px;border-radius:999px;background:var(--c-accent-soft);color:var(--c-accent);display:grid;place-items:center;margin:0 auto 24px;">
        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
      </div>
      <h1 style="font-size:42px;margin-bottom:16px;">Order placed!</h1>
      <p style="color:var(--c-ink-2);max-width:40ch;margin:0 auto 32px;">A confirmation has been sent to <strong>${last.email || 'your email'}</strong>. Your order <strong>#${last.id || ''}</strong> is being prepared.</p>
      <div style="display:flex;gap:12px;justify-content:center;">
        <a href="/store/" class="btn btn-secondary">Continue shopping</a>
        <a href="/store/products.html" class="btn btn-primary">Browse more</a>
      </div>
    </div>
  `;
} else {
  render();
}
