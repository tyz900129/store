// pages/detail.js
import { fetchProduct, fetchProducts, fetchReviews, money, FALLBACK } from '../data.js';
import { icon, toast } from '../ui.js';
import { addToCart } from '../cart.js';

const params = new URLSearchParams(location.search);
const id = params.get('id') || 1;

let product = null;
let reviews = [];
let selectedColor = null;
let selectedSize = null;
let qty = 1;
let activeImg = 0;

function stars(n) {
  const full = Math.round(n);
  return '★'.repeat(full) + '☆'.repeat(5 - full);
}

function render() {
  const root = document.getElementById('detailRoot');
  if (!product) { root.innerHTML = '<p>Product not found.</p>'; return; }
  selectedColor = product.colors ? product.colors[0] : null;
  selectedSize = product.sizes ? product.sizes[0] : null;

  root.innerHTML = `
    <div class="detail-page">
      <div class="gallery">
        <div class="main">
          <img id="mainImg" src="${product.images[activeImg]}" alt="${product.title}">
        </div>
        <div class="thumbs" id="thumbs">
          ${product.images.map((src, i) => `
            <button class="${i===activeImg?'active':''}" data-i="${i}">
              <img src="${src}" alt="">
            </button>
          `).join('')}
        </div>
      </div>
      <div class="detail-info">
        <div class="crumbs">
          <a href="/store/">Home</a><span>/</span>
          <a href="/store/products.html?category=${product.category}">${product.category}</a><span>/</span>
          <span>${product.title}</span>
        </div>
        <span class="tag brand">${product.badge || 'New arrival'}</span>
        <h1 style="margin-top:12px;">${product.title}</h1>
        <div style="display:flex;align-items:center;gap:12px;color:var(--c-ink-3);font-size:14px;">
          <span style="color:var(--c-sun);letter-spacing:1px;">${stars(product.rating)}</span>
          <span>${product.rating.toFixed(1)} · ${reviews.length} reviews · ${product.stock} in stock</span>
        </div>
        <div class="price-line">
          <span class="price">${money(product.price, product.currency)}</span>
          ${product.originalPrice ? `<span class="orig">${money(product.originalPrice, product.currency)}</span><span class="save">-${Math.round((1-product.price/product.originalPrice)*100)}%</span>` : ''}
        </div>
        <p style="color:var(--c-ink-2);">${product.description}</p>

        ${product.colors ? `
          <div class="spec-group">
            <span class="lbl">Color · <strong id="colorName">${selectedColor.name}</strong></span>
            <div class="color-row" id="colorRow">
              ${product.colors.map(c => `<button data-color="${c.id}" class="${c.id===selectedColor.id?'active':''}" style="background:${c.hex};" aria-label="${c.name}"></button>`).join('')}
            </div>
          </div>` : ''}

        ${product.sizes ? `
          <div class="spec-group">
            <span class="lbl">Size</span>
            <div class="size-row" id="sizeRow">
              ${product.sizes.map(s => `<button data-size="${s}" class="${s===selectedSize?'active':''}">${s}</button>`).join('')}
            </div>
          </div>` : ''}

        <div class="detail-actions">
          <div class="qty">
            <button id="decQty" aria-label="Decrease">${icon('minus')}</button>
            <input id="qtyInput" value="1" readonly>
            <button id="incQty" aria-label="Increase">${icon('plus')}</button>
          </div>
          <button class="btn btn-primary btn-lg" id="addBtn" style="flex:1;">Add to cart · ${money(product.price, product.currency)}</button>
        </div>
        <button class="btn btn-secondary btn-block" id="buyNow">Buy it now</button>

        <div class="detail-features">
          <div class="feature">
            <div class="ic">${icon('truck')}</div>
            <div><h5>Free worldwide shipping</h5><p>On orders over $80</p></div>
          </div>
          <div class="feature">
            <div class="ic">${icon('shield')}</div>
            <div><h5>2-year warranty</h5><p>Built to last</p></div>
          </div>
          <div class="feature">
            <div class="ic">${icon('leaf')}</div>
            <div><h5>Sustainably made</h5><p>Recycled & natural materials</p></div>
          </div>
          <div class="feature">
            <div class="ic">${icon('arrow')}</div>
            <div><h5>30-day returns</h5><p>No questions asked</p></div>
          </div>
        </div>
      </div>
    </div>

    <div class="tabs">
      <div class="tab-head">
        <button class="tab-btn active" data-tab="desc">Description</button>
        <button class="tab-btn" data-tab="specs">Specs</button>
        <button class="tab-btn" data-tab="reviews">Reviews (${reviews.length})</button>
        <button class="tab-btn" data-tab="shipping">Shipping</button>
      </div>
      <div class="tab-panel active" data-panel="desc">
        <p style="max-width:72ch;color:var(--c-ink-2);">${product.description}</p>
        <p style="max-width:72ch;color:var(--c-ink-2);">Each piece is hand-finished in our Brooklyn studio by a small team of craftspeople. We use natural materials wherever we can — wool, cotton, leather, ceramic — and partner with family-run mills and tanneries that share our values.</p>
      </div>
      <div class="tab-panel" data-panel="specs">
        <table style="width:100%;max-width:560px;border-collapse:collapse;">
          ${(product.specs||[]).map(s => `<tr style="border-bottom:1px solid var(--c-line);"><td style="padding:12px 0;color:var(--c-ink-3);font-size:14px;width:40%;">${s.k}</td><td style="padding:12px 0;font-size:14px;font-weight:500;">${s.v}</td></tr>`).join('')}
        </table>
      </div>
      <div class="tab-panel" data-panel="reviews">
        <div class="reviews">
          ${reviews.length === 0 ? '<p style="color:var(--c-ink-3);">No reviews yet.</p>' :
            reviews.map(r => `
              <div class="review">
                <div class="top">
                  <div>
                    <div class="stars">${stars(r.rating)}</div>
                    <div class="author">${r.author}</div>
                  </div>
                  <div class="date">${r.date}</div>
                </div>
                <p style="margin:0;color:var(--c-ink-2);">${r.content}</p>
              </div>
            `).join('')}
        </div>
      </div>
      <div class="tab-panel" data-panel="shipping">
        <ul style="max-width:60ch;color:var(--c-ink-2);line-height:1.8;">
          <li>Standard shipping (5-8 business days): Free over $80, otherwise $8</li>
          <li>Express shipping (2-4 business days): $18</li>
          <li>International shipping available to 40+ countries</li>
          <li>30-day return window, full refund</li>
          <li>All items ship in recyclable packaging</li>
        </ul>
      </div>
    </div>

    <div class="section">
      <div class="section-head">
        <div>
          <span class="eyebrow">You may also like</span>
          <h2>From the same family</h2>
        </div>
        <a href="/store/products.html" class="btn btn-ghost">View all ${icon('arrow')}</a>
      </div>
      <div class="product-grid" id="relatedGrid"></div>
    </div>
  `;

  bind();
  renderRelated();
}

function bind() {
  // 缩略图
  document.getElementById('thumbs').addEventListener('click', (e) => {
    const b = e.target.closest('button');
    if (!b) return;
    activeImg = Number(b.dataset.i);
    document.getElementById('mainImg').src = product.images[activeImg];
    document.querySelectorAll('#thumbs button').forEach((x,i) => x.classList.toggle('active', i===activeImg));
  });
  // 颜色
  const colorRow = document.getElementById('colorRow');
  if (colorRow) colorRow.addEventListener('click', (e) => {
    const b = e.target.closest('button');
    if (!b) return;
    selectedColor = product.colors.find(c => c.id === b.dataset.color);
    colorRow.querySelectorAll('button').forEach(x => x.classList.toggle('active', x === b));
    document.getElementById('colorName').textContent = selectedColor.name;
  });
  // 尺寸
  const sizeRow = document.getElementById('sizeRow');
  if (sizeRow) sizeRow.addEventListener('click', (e) => {
    const b = e.target.closest('button');
    if (!b) return;
    selectedSize = b.dataset.size;
    sizeRow.querySelectorAll('button').forEach(x => x.classList.toggle('active', x === b));
  });
  // 数量
  const qtyInput = document.getElementById('qtyInput');
  document.getElementById('decQty').addEventListener('click', () => {
    qty = Math.max(1, qty - 1);
    qtyInput.value = qty;
  });
  document.getElementById('incQty').addEventListener('click', () => {
    qty = Math.min(product.stock, qty + 1);
    qtyInput.value = qty;
  });
  // 加入购物车
  document.getElementById('addBtn').addEventListener('click', () => {
    addToCart(product, qty, { color: selectedColor?.id, size: selectedSize });
    toast('Added to cart', 'success');
  });
  // 立即购买
  document.getElementById('buyNow').addEventListener('click', () => {
    addToCart(product, qty, { color: selectedColor?.id, size: selectedSize });
    location.href = '/store/checkout.html';
  });
  // tabs
  document.querySelectorAll('.tab-btn').forEach(b => b.addEventListener('click', () => {
    document.querySelectorAll('.tab-btn').forEach(x => x.classList.toggle('active', x === b));
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.toggle('active', p.dataset.panel === b.dataset.tab));
  }));
}

async function renderRelated() {
  const { items } = await fetchProducts({ category: product.category });
  const others = items.filter(p => p.id !== product.id).slice(0, 4);
  const grid = document.getElementById('relatedGrid');
  if (!grid) return;
  grid.innerHTML = others.map(p => {
    const img1 = p.images[0] || '';
    const img2 = p.images[1] || img1;
    return `
      <article class="card">
        <a href="/store/product.html?id=${p.id}" class="thumb">
          <img class="main" src="${img1}" alt="${p.title}">
          <img class="alt" src="${img2}" alt="">
        </a>
        <div class="body">
          <div class="meta">
            <span>${p.pet === 'cat' ? 'Cat' : p.pet === 'dog' ? 'Dog' : 'All Pets'}</span>
            <span>${icon('star')} ${p.rating.toFixed(1)}</span>
          </div>
          <h3><a href="/store/product.html?id=${p.id}">${p.title}</a></h3>
          <div class="price-row">
            <span class="price">${money(p.price, p.currency)}</span>
            <button class="add" data-add-to-cart="${p.id}" aria-label="Add to cart">${icon('plus')}</button>
          </div>
        </div>
      </article>
    `;
  }).join('');
}

async function init() {
  product = await fetchProduct(id) || FALLBACK.products[0];
  reviews = await fetchReviews(product.id);
  render();
}

init();
