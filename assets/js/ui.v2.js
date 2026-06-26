// ui.js · 通用 UI 工具（toast / 图标 / 移动端抽屉）

export function toast(message, type = '') {
  let el = document.querySelector('.toast');
  if (!el) {
    el = document.createElement('div');
    el.className = 'toast';
    document.body.appendChild(el);
  }
  el.className = 'toast ' + type;
  el.textContent = message;
  requestAnimationFrame(() => el.classList.add('show'));
  clearTimeout(el._t);
  el._t = setTimeout(() => el.classList.remove('show'), 2400);
}

export function money(n, currency) {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: currency || 'USD' }).format(n);
}

// 图标：内联 SVG（无外部依赖）
const ICONS = {
  search: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></svg>',
  cart:  '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="8" cy="21" r="1"/><circle cx="19" cy="21" r="1"/><path d="M2.05 2.05h2l2.66 12.42a2 2 0 0 0 2 1.58h9.78a2 2 0 0 0 1.95-1.57l1.65-7.43H5.12"/></svg>',
  user:  '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>',
  heart: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.29 1.51 4.04 3 5.5l7 7Z"/></svg>',
  menu:  '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="4" x2="20" y1="6" y2="6"/><line x1="4" x2="20" y1="12" y2="12"/><line x1="4" x2="20" y1="18" y2="18"/></svg>',
  x:     '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>',
  arrow: '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>',
  truck: '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 18V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v11a1 1 0 0 0 1 1h2"/><path d="M15 18H9"/><path d="M19 18h2a1 1 0 0 0 1-1v-3.65a1 1 0 0 0-.22-.624l-3.48-4.35A1 1 0 0 0 17.52 8H14"/><circle cx="17" cy="18" r="2"/><circle cx="7" cy="18" r="2"/></svg>',
  shield:'<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/></svg>',
  leaf:  '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19.2 2.96c1.4 9.3 -2 14.47-8.2 17.04"/><path d="M2 21c0-3 1.85-5.36 5.08-6"/></svg>',
  star:  '<svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2"><path d="M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a2.123 2.123 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 3.638a2.123 2.123 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-2.428a2.122 2.122 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-5.139a2.122 2.122 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l5.165-.755a2.122 2.122 0 0 0 1.597-1.16z"/></svg>',
  plus:  '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5v14"/></svg>',
  minus: '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/></svg>',
  trash: '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/><path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>',
  bed:   '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 4v16"/><path d="M2 8h18a2 2 0 0 1 2 2v10"/><path d="M2 17h20"/><path d="M6 8v9"/></svg>',
  toy:   '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v10"/><path d="M9 9.5c0-1 1-1.5 2-1.5s2 .5 2 1.5-1 1.5-2 1.5-2 .5-2 1.5 1 1.5 2 1.5 2-.5 2-1.5"/></svg>',
  shirt: '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20.38 3.46 16 2a4 4 0 0 1-8 0L3.62 3.46a2 2 0 0 0-1.34 2.23l.58 3.47a1 1 0 0 0 .99.84H6v10c0 1.1.9 2 2 2h8a2 2 0 0 0 2-2V10h2.15a1 1 0 0 0 .99-.84l.58-3.47a2 2 0 0 0-1.34-2.23z"/></svg>',
  bowl:  '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12h20"/><path d="M3 12a9 9 0 0 0 18 0"/></svg>',
  compass:'<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"/></svg>',
  cpu:   '<svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="4" width="16" height="16" rx="2"/><rect x="9" y="9" width="6" height="6"/><path d="M15 2v2"/><path d="M15 20v2"/><path d="M2 15h2"/><path d="M2 9h2"/><path d="M20 15h2"/><path d="M20 9h2"/><path d="M9 2v2"/><path d="M9 20v2"/></svg>',
  mail:  '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/></svg>',
  phone: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>',
  pin:   '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 10c0 7-8 13-8 13s-8-6-8-13a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>',
};

export function icon(name) {
  return ICONS[name] || '';
}

export function mountHeader(active) {
  const header = document.getElementById('site-header');
  if (!header) return;
  header.innerHTML = `
    <div class="container">
      <nav class="nav">
        <a href="/store/" class="brand">
          <span class="logo">P</span>
          <span>PawPatrol<small>Pet Goods · Est. 2026</small></span>
        </a>
        <ul class="primary">
          <li><a href="/store/" class="nav-link ${active==='home'?'active':''}">Home</a></li>
          <li><a href="/store/products.html" class="nav-link ${active==='list'?'active':''}">Shop</a></li>
          <li><a href="/store/products.html?pet=cat" class="nav-link">Cats</a></li>
          <li><a href="/store/products.html?pet=dog" class="nav-link">Dogs</a></li>
          <li><a href="/store/about.html" class="nav-link ${active==='about'?'active':''}">About</a></li>
          <li><a href="/store/contact.html" class="nav-link ${active==='contact'?'active':''}">Contact</a></li>
        </ul>
        <span class="spacer"></span>
        <button class="icon-btn secondary" id="navSearch" aria-label="Search">${icon('search')}</button>
        <button class="icon-btn secondary" id="navUser" aria-label="Account">${icon('user')}</button>
        <a href="/store/cart.html" class="icon-btn" id="navCart" aria-label="Cart">
          ${icon('cart')}
          <span class="badge" id="cartBadge" style="display:none">0</span>
        </a>
        <button class="nav-toggle" id="navToggle" aria-label="Menu">${icon('menu')}</button>
      </nav>
    </div>
    <aside class="drawer" id="mobileDrawer">
      <ul>
        <li><a href="/store/">Home</a></li>
        <li><a href="/store/products.html">Shop</a></li>
        <li><a href="/store/products.html?pet=cat">Cats</a></li>
        <li><a href="/store/products.html?pet=dog">Dogs</a></li>
        <li><a href="/store/about.html">About</a></li>
        <li><a href="/store/contact.html">Contact</a></li>
      </ul>
    </aside>
  `;
  // 抽屉
  const drawer = document.getElementById('mobileDrawer');
  document.getElementById('navToggle').addEventListener('click', () => {
    drawer.classList.toggle('open');
  });
  drawer.querySelectorAll('a').forEach(a => a.addEventListener('click', () => drawer.classList.remove('open')));
}

export function mountFooter() {
  const f = document.getElementById('site-footer');
  if (!f) return;
  f.innerHTML = `
    <div class="container">
      <div class="footer-grid">
        <div class="footer-col">
          <a href="/store/" class="brand" style="color:#fff;font-family:var(--f-display);font-weight:700;font-size:22px;display:inline-flex;align-items:center;gap:10px;">
            <span class="logo" style="width:36px;height:36px;display:grid;place-items:center;background:var(--c-sun);color:var(--c-ink);border-radius:10px;">P</span>
            PawPatrol
          </a>
          <p style="margin-top:16px;">Thoughtfully designed pet goods for the people who treat their pets like family. Ships worldwide from our studio in Brooklyn.</p>
          <div class="footer-newsletter" style="margin-top:24px;">
            <form id="footerSub">
              <input type="email" placeholder="Get 10% off your first order" required>
            </form>
          </div>
        </div>
        <div class="footer-col">
          <h4>Shop</h4>
          <ul>
            <li><a href="/store/products.html?pet=cat">For Cats</a></li>
            <li><a href="/store/products.html?pet=dog">For Dogs</a></li>
            <li><a href="/store/products.html?pet=small">For Small Pets</a></li>
            <li><a href="/store/products.html">All Products</a></li>
            <li><a href="/store/products.html?sale=1">Sale</a></li>
          </ul>
        </div>
        <div class="footer-col">
          <h4>Company</h4>
          <ul>
            <li><a href="/store/about.html">About Us</a></li>
            <li><a href="/store/about.html#story">Sustainability</a></li>
            <li><a href="/store/contact.html">Contact</a></li>
            <li><a href="#">Careers</a></li>
            <li><a href="#">Press</a></li>
          </ul>
        </div>
        <div class="footer-col">
          <h4>Support</h4>
          <ul>
            <li><a href="/store/contact.html#faq">FAQ</a></li>
            <li><a href="#">Shipping & Returns</a></li>
            <li><a href="#">Order Tracking</a></li>
            <li><a href="#">Privacy</a></li>
            <li><a href="#">Terms</a></li>
          </ul>
        </div>
      </div>
      <div class="footer-bottom">
        <span>© 2026 PawPatrol Goods Co. · Brooklyn, NY</span>
        <span>Made with 🐾 on Earth</span>
      </div>
    </div>
  `;
  // 订阅
  const f1 = document.getElementById('footerSub');
  if (f1) f1.addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = f1.querySelector('input').value.trim();
    if (!email) return;
    const { subscribeEmail } = await import('./data.v2.js');
    await subscribeEmail(email);
    toast('Thanks! Check your inbox for the code.', 'success');
    f1.reset();
  });
}

export function updateCartBadge() {
  const badge = document.getElementById('cartBadge');
  if (!badge) return;
  // 通过动态 import 避免循环
  import('./cart.v2.js').then(({ cartCount }) => {
    const n = cartCount();
    badge.textContent = n;
    badge.style.display = n > 0 ? 'grid' : 'none';
  });
}

// 把全局点击"加入购物车"按钮的逻辑集中
export function bindAddToCart(root = document) {
  root.addEventListener('click', async (e) => {
    const btn = e.target.closest('[data-add-to-cart]');
    if (!btn) return;
    const id = btn.dataset.addToCart;
    const { fetchProduct, FALLBACK } = await import('./data.v2.js');
    const { addToCart } = await import('./cart.v2.js');
    const p = await fetchProduct(id) || FALLBACK.products.find(x => String(x.id) === String(id));
    if (!p) return;
    addToCart(p, 1);
    toast('Added to cart', 'success');
  });
}
