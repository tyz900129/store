// cart.js · 购物车（基于 LocalStorage）

const KEY = 'pp_cart_v1';

function read() {
  try { return JSON.parse(localStorage.getItem(KEY) || '[]'); }
  catch { return []; }
}

function write(items) {
  localStorage.setItem(KEY, JSON.stringify(items));
  window.dispatchEvent(new CustomEvent('cart:change', { detail: { items } }));
}

export function getCart() { return read(); }

export function addToCart(product, qty = 1, variant = null) {
  const items = read();
  const key = product.id + '::' + (variant ? variant.color + '/' + variant.size : 'default');
  const exist = items.find(i => i.key === key);
  if (exist) exist.qty += qty;
  else items.push({
    key,
    id: product.id,
    title: product.title,
    price: product.price,
    image: (product.images && product.images[0]) || '',
    variant,
    qty,
  });
  write(items);
  return items;
}

export function updateQty(key, qty) {
  const items = read();
  const it = items.find(i => i.key === key);
  if (!it) return;
  it.qty = Math.max(1, qty);
  write(items);
}

export function removeItem(key) {
  write(read().filter(i => i.key !== key));
}

export function clearCart() { write([]); }

export function cartCount() {
  return read().reduce((s, i) => s + i.qty, 0);
}

export function cartTotal() {
  return read().reduce((s, i) => s + i.qty * i.price, 0);
}
