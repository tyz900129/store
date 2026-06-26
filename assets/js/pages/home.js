// pages/home.js
import { fetchCategories, fetchProducts, money } from '../data.js';
import { icon } from '../ui.js';

const CAT_IMGS = {
  bed: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=cozy%20round%20wool%20pet%20bed%20in%20warm%20living%20room%2C%20lifestyle%2C%20square%20format&image_size=square',
  toy: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=colorful%20eco%20pet%20toys%20arranged%20on%20wood%20floor%2C%20flat%20lay%2C%20cheerful%20tones&image_size=square',
  apparel: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=stylish%20pet%20apparel%20on%20wooden%20hanger%2C%20boutique%20style%2C%20warm%20light&image_size=square',
  bowl: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=ceramic%20pet%20bowl%20in%20sage%20green%20with%20kibble%2C%20minimal%20product%20photo&image_size=square',
  travel: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=modern%20canvas%20pet%20carrier%20backpack%20in%20beige%2C%20product%20photo&image_size=square',
  smart: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=modern%20pet%20smart%20fountain%20white%20and%20blue%2C%20product%20photo&image_size=square',
};

function catCard(c) {
  return `
    <a href="/store/products.html?category=${c.id}" class="cat">
      <div class="ic" style="overflow:hidden;border-radius:999px;">
        <img src="${CAT_IMGS[c.id]}" alt="${c.name}" style="width:60px;height:60px;object-fit:cover;">
      </div>
      <div class="nm">${c.name}</div>
      <div class="ct">${c.count} items</div>
    </a>
  `;
}

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

async function render() {
  const [cats, products] = await Promise.all([
    fetchCategories(),
    fetchProducts(),
  ]);

  const catsEl = document.getElementById('catRow');
  if (catsEl) catsEl.innerHTML = cats.map(catCard).join('');

  const grid = document.getElementById('featuredGrid');
  if (grid) grid.innerHTML = products.items.slice(0, 8).map(productCard).join('');

  const newGrid = document.getElementById('newGrid');
  if (newGrid) newGrid.innerHTML = products.items.slice(4, 8).map(productCard).join('');
}

render();
