// pages/cart.js
import { getCart, updateQty, removeItem, cartTotal } from '../cart.v4.js';
import { money, icon, toast } from '../ui.v4.js';

function row(item) {
  return `
    <div class="cart-row">
      <div class="pic"><img src="${item.image}" alt="${item.title}"></div>
      <div class="info">
        <h4><a href="/store/product.html?id=${item.id}">${item.title}</a></h4>
        <div class="variant">${item.variant ? `${item.variant.color || ''} ${item.variant.size ? '/ ' + item.variant.size : ''}` : ''}</div>
        <div class="price">${money(item.price)}</div>
      </div>
      <div class="qty">
        <button data-act="dec" data-key="${item.key}" aria-label="Decrease">${icon('minus')}</button>
        <input value="${item.qty}" readonly>
        <button data-act="inc" data-key="${item.key}" aria-label="Increase">${icon('plus')}</button>
      </div>
      <div class="total">${money(item.price * item.qty)}</div>
      <button class="remove" data-act="del" data-key="${item.key}" aria-label="Remove">${icon('trash')}</button>
    </div>
  `;
}

function render() {
  const items = getCart();
  const wrap = document.getElementById('cartTable');
  const empty = document.getElementById('cartEmpty');
  const summary = document.getElementById('cartSummary');
  if (items.length === 0) {
    if (wrap) wrap.style.display = 'none';
    if (summary) summary.style.display = 'none';
    if (empty) empty.style.display = 'block';
    return;
  }
  if (wrap) {
    wrap.style.display = 'block';
    wrap.innerHTML = `
      <div class="cart-row" style="font-size:12px;text-transform:uppercase;letter-spacing:.12em;color:var(--c-ink-3);border-bottom:1px solid var(--c-line);">
        <div></div><div>Product</div><div>Quantity</div><div>Total</div><div></div>
      </div>
      ${items.map(row).join('')}
    `;
  }
  const sub = cartTotal();
  const shipping = sub >= 80 ? 0 : 8;
  const tax = sub * 0.05;
  const total = sub + shipping + tax;
  if (summary) {
    summary.style.display = 'block';
    summary.innerHTML = `
      <h3>Order summary</h3>
      <div class="summary-row"><span>Subtotal</span><span>${money(sub)}</span></div>
      <div class="summary-row"><span>Shipping</span><span>${shipping === 0 ? 'Free' : money(shipping)}</span></div>
      <div class="summary-row"><span>Estimated tax</span><span>${money(tax)}</span></div>
      <div class="coupon-row">
        <input placeholder="Discount code" id="coupon">
        <button class="btn btn-secondary btn-sm" id="applyCoupon">Apply</button>
      </div>
      <div class="summary-row total"><span>Total</span><span>${money(total)}</span></div>
      <button class="btn btn-primary btn-block btn-lg" id="goCheckout" style="margin-top:16px;">Checkout ${icon('arrow')}</button>
      <p style="font-size:12px;color:var(--c-ink-3);text-align:center;margin-top:12px;">Free worldwide shipping over $80</p>
    `;
  }
}

document.addEventListener('click', (e) => {
  const b = e.target.closest('[data-act]');
  if (!b) return;
  const { act, key } = b.dataset;
  const items = getCart();
  const it = items.find(i => i.key === key);
  if (!it) return;
  if (act === 'inc') updateQty(key, it.qty + 1);
  if (act === 'dec') updateQty(key, it.qty - 1);
  if (act === 'del') {
    removeItem(key);
    toast('Item removed');
  }
  render();
});

document.addEventListener('click', (e) => {
  if (e.target.id === 'goCheckout') location.href = '/store/checkout.html';
  if (e.target.id === 'applyCoupon') {
    const v = document.getElementById('coupon').value.trim();
    if (v) toast('Code "' + v + '" accepted', 'success');
  }
});

render();
