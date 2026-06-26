// pages/list.js
import { fetchCategories, fetchProducts, money } from '../data.v2.js';
import { icon } from '../ui.v2.js';

const params = new URLSearchParams(location.search);
let state = {
  category: params.get('category') || '',
  pet: params.get('pet') || 'all',
  maxPrice: 200,
  sort: 'popular',
  q: params.get('q') || '',
};

function productCard(p) {
  const img1 = p.images[0] || '';
  const img2 = p.images[1] || img1;
  return `
    <article class="card">
      ${p.badge ? `<span class="tag brand badge-corner">${p.badge}</span>` : ''}
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
}

function filterItem(c) {
  const active = state.category === c.id ? 'checked' : '';
  return `
    <label>
      <input type="checkbox" data-filter-cat="${c.id}" ${active}>
      <span>${c.name}</span>
      <span class="count">${c.count}</span>
    </label>
  `;
}

function petFilter() {
  return `
    <label><input type="radio" name="pet" value="all" ${state.pet==='all'?'checked':''}> All pets</label>
    <label><input type="radio" name="pet" value="cat" ${state.pet==='cat'?'checked':''}> Cats</label>
    <label><input type="radio" name="pet" value="dog" ${state.pet==='dog'?'checked':''}> Dogs</label>
    <label><input type="radio" name="pet" value="small" ${state.pet==='small'?'checked':''}> Small pets</label>
  `;
}

async function render() {
  const [cats, data] = await Promise.all([
    fetchCategories(),
    fetchProducts({
      category: state.category || undefined,
      pet: state.pet !== 'all' ? state.pet : undefined,
      q: state.q || undefined,
    }),
  ]);

  // 筛选 cats
  const filterEl = document.getElementById('catFilters');
  if (filterEl) filterEl.innerHTML = cats.map(filterItem).join('');
  const petEl = document.getElementById('petFilters');
  if (petEl) petEl.innerHTML = petFilter();

  // 价格筛选
  let items = data.items.filter(p => p.price <= state.maxPrice);

  // 排序
  if (state.sort === 'price-asc') items.sort((a,b) => a.price - b.price);
  if (state.sort === 'price-desc') items.sort((a,b) => b.price - a.price);
  if (state.sort === 'new') items.sort((a,b) => b.id - a.id);
  if (state.sort === 'rating') items.sort((a,b) => b.rating - a.rating);

  const grid = document.getElementById('productGrid');
  if (grid) grid.innerHTML = items.length ? items.map(productCard).join('')
    : '<p style="grid-column:1/-1;text-align:center;color:var(--c-ink-3);padding:48px 0;">No products match your filters.</p>';

  const ct = document.getElementById('countText');
  if (ct) ct.textContent = `${items.length} product${items.length===1?'':'s'}`;

  const ttl = document.getElementById('listTitle');
  if (ttl) {
    const cat = cats.find(c => c.id === state.category);
    if (state.q) ttl.textContent = `Results for "${state.q}"`;
    else if (cat) ttl.textContent = cat.name;
    else if (state.pet !== 'all') ttl.textContent = state.pet === 'cat' ? 'For Cats' : state.pet === 'dog' ? 'For Dogs' : 'Small Pets';
    else ttl.textContent = 'All Products';
  }
}

function bind() {
  // 分类
  document.addEventListener('change', (e) => {
    if (e.target.matches('[data-filter-cat]')) {
      const id = e.target.dataset.filterCat;
      state.category = e.target.checked ? id : '';
      const u = new URL(location.href);
      if (state.category) u.searchParams.set('category', state.category);
      else u.searchParams.delete('category');
      history.replaceState(null, '', u);
      render();
    }
    if (e.target.matches('input[name="pet"]')) {
      state.pet = e.target.value;
      const u = new URL(location.href);
      if (state.pet !== 'all') u.searchParams.set('pet', state.pet);
      else u.searchParams.delete('pet');
      history.replaceState(null, '', u);
      render();
    }
  });
  // 排序
  document.addEventListener('change', (e) => {
    if (e.target.id === 'sortSelect') {
      state.sort = e.target.value;
      render();
    }
  });
  // 价格
  const range = document.getElementById('priceRange');
  const priceVal = document.getElementById('priceVal');
  if (range) {
    range.addEventListener('input', () => {
      state.maxPrice = Number(range.value);
      if (priceVal) priceVal.textContent = '$' + state.maxPrice;
      render();
    });
  }
  // 搜索
  const searchInput = document.getElementById('searchInput');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      state.q = e.target.value;
      render();
    });
  }
}

bind();
render();
