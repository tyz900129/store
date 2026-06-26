// data.js · mock 数据 + API 封装
// 优先调用 JSP 后端（/api/*.jsp）；若失败则回退到本地 mock，保证框架可独立运行

const ENDPOINTS = {
  products: '/store/api/products.jsp',
  categories: '/store/api/categories.jsp',
  subscribe: '/store/api/subscribe.jsp',
  order: '/store/api/order.jsp',
};

const FALLBACK = {
  categories: [
    { id: 'bed', name: 'Beds & Caves', icon: 'bed', count: 18 },
    { id: 'toy', name: 'Toys', icon: 'toy', count: 32 },
    { id: 'apparel', name: 'Apparel', icon: 'shirt', count: 24 },
    { id: 'bowl', name: 'Bowls & Diners', icon: 'bowl', count: 14 },
    { id: 'travel', name: 'Travel & Walk', icon: 'compass', count: 20 },
    { id: 'smart', name: 'Smart Gear', icon: 'cpu', count: 9 },
  ],
  products: [
    {
      id: 1, title: 'Cloud Nine Cat Cave', slug: 'cloud-nine-cat-cave',
      price: 49, currency: 'USD', originalPrice: 65,
      category: 'bed', pet: 'cat', rating: 4.9, stock: 23,
      images: [
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=minimalist%20wool%20felt%20cat%20cave%20in%20warm%20terracotta%20on%20wooden%20floor%2C%20studio%20lighting%2C%20e-commerce%20photo&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=cute%20tabby%20cat%20sleeping%20inside%20a%20round%20wool%20cave%2C%20cozy%20warm%20light%2C%20lifestyle%20photo&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=top%20down%20view%20of%20handmade%20wool%20felt%20cat%20cave%20on%20oak%20floor%2C%20product%20photography&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=close%20up%20texture%20detail%20of%20wool%20felt%20fabric%2C%20handmade%20craft%2C%20warm%20tone&image_size=square_hd',
      ],
      badge: 'Best seller',
      description: 'Hand-felted from 100% New Zealand wool, our Cloud Nine cave gives your cat a snug, temperature-stable retreat. The curved silhouette muffles sound and the natural fibers are hypoallergenic.',
      specs: [
        { k: 'Material', v: '100% New Zealand wool' },
        { k: 'Diameter', v: '40 cm / 15.7 in' },
        { k: 'Weight', v: '1.2 kg' },
        { k: 'Care', v: 'Spot clean, air dry' },
        { k: 'Suitable for', v: 'Cats up to 6 kg' },
      ],
      colors: [
        { id: 'terracotta', name: 'Terracotta', hex: '#E07856' },
        { id: 'sage', name: 'Sage', hex: '#9CB29A' },
        { id: 'cream', name: 'Cream', hex: '#F2EAD6' },
        { id: 'slate', name: 'Slate', hex: '#4A5560' },
      ],
      sizes: ['S', 'M', 'L'],
    },
    {
      id: 2, title: 'Bark & Breeze Leash', slug: 'bark-breeze-leash',
      price: 36, currency: 'USD',
      category: 'travel', pet: 'dog', rating: 4.8, stock: 50,
      images: [
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=premium%20tan%20leather%20dog%20leash%20with%20brass%20clip%20on%20marble%20surface%2C%20product%20photo%2C%20warm%20light&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=close%20up%20of%20brass%20carabiner%20clip%20on%20leather%20dog%20leash%2C%20craft%20detail%2C%20macro%20photography&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=happy%20golden%20retriever%20walking%20with%20leather%20leash%20in%20park%2C%20sunset%20light%2C%20lifestyle&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=rolled%20leather%20leash%20with%20natural%20grain%20texture%2C%20product%20flat%20lay&image_size=square_hd',
      ],
      badge: 'New',
      description: 'Vegetable-tanned leather, hand-stitched with marine-grade brass. Softens with use, develops a patina, and lasts years of daily walks.',
      specs: [
        { k: 'Material', v: 'Vegetable-tanned leather + brass' },
        { k: 'Length', v: '120 cm / 4 ft' },
        { k: 'Width', v: '1.8 cm' },
        { k: 'Hardware', v: 'Solid brass carabiner' },
        { k: 'Suitable for', v: 'Small to large dogs' },
      ],
      colors: [
        { id: 'tan', name: 'Tan', hex: '#C4936A' },
        { id: 'cognac', name: 'Cognac', hex: '#8B4513' },
        { id: 'black', name: 'Black', hex: '#1F1A14' },
      ],
      sizes: ['S', 'M', 'L'],
    },
    {
      id: 3, title: 'Pebble Ceramic Bowl', slug: 'pebble-ceramic-bowl',
      price: 28, currency: 'USD',
      category: 'bowl', pet: 'cat', rating: 4.7, stock: 80,
      images: [
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=minimalist%20matte%20ceramic%20pet%20bowl%20in%20sage%20green%20on%20linen%2C%20product%20photo%2C%20natural%20light&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=overhead%20view%20of%20two%20ceramic%20pet%20bowls%20in%20sage%20and%20cream%2C%20flat%20lay%2C%20warm%20tone&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=close%20up%20of%20ceramic%20glaze%20texture%20on%20pet%20bowl%2C%20macro%20photography&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=cat%20eating%20from%20ceramic%20bowl%20in%20modern%20kitchen%2C%20lifestyle%20photo&image_size=square_hd',
      ],
      description: 'Dishwasher-safe stoneware with a weighted base to prevent sliding. The shallow, wide shape is ergonomically designed to be whisker-friendly.',
      specs: [
        { k: 'Material', v: 'Glazed stoneware' },
        { k: 'Capacity', v: '450 ml' },
        { k: 'Diameter', v: '16 cm' },
        { k: 'Dishwasher safe', v: 'Yes' },
      ],
      colors: [
        { id: 'sage', name: 'Sage', hex: '#9CB29A' },
        { id: 'cream', name: 'Cream', hex: '#F2EAD6' },
        { id: 'clay', name: 'Clay', hex: '#C4936A' },
      ],
      sizes: ['350ml', '450ml', '700ml'],
    },
    {
      id: 4, title: 'Wiggle Wand Refill Set', slug: 'wiggle-wand-refill',
      price: 18, currency: 'USD',
      category: 'toy', pet: 'cat', rating: 4.9, stock: 120,
      images: [
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=colorful%20eco%20feather%20cat%20toy%20refills%20on%20kraft%20paper%2C%20product%20flat%20lay%2C%20bright%20cheerful&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=playful%20kitten%20chasing%20feather%20wand%20in%20living%20room%2C%20lifestyle%20photo&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=set%20of%20six%20natural%20feather%20cat%20toys%20arranged%20neatly%2C%20craft%20photo&image_size=square_hd',
      ],
      description: 'Six natural feather refills made from responsibly sourced materials. Connects to any standard wand handle (sold separately).',
      specs: [
        { k: 'Quantity', v: '6 refills' },
        { k: 'Material', v: 'Natural feathers, sisal' },
      ],
      colors: [
        { id: 'rainbow', name: 'Rainbow', hex: 'linear-gradient(135deg,#E07856,#F2B541,#9CB29A)' },
        { id: 'earth', name: 'Earth', hex: '#8B7355' },
      ],
    },
    {
      id: 5, title: 'Trailblazer Carrier', slug: 'trailblazer-carrier',
      price: 89, currency: 'USD', originalPrice: 110,
      category: 'travel', pet: 'cat', rating: 4.6, stock: 30,
      images: [
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=modern%20beige%20canvas%20pet%20carrier%20backpack%20on%20white%20background%2C%20product%20photo%2C%20minimalist&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=person%20wearing%20pet%20carrier%20backpack%20walking%20in%20city%2C%20lifestyle%20photo&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=detail%20of%20mesh%20ventilation%20window%20on%20pet%20carrier%2C%20macro%20photo&image_size=square_hd',
      ],
      badge: '-19%',
      description: 'Roomy, breathable, and stylish. The Trailblazer fits cats up to 6 kg and folds flat for easy storage.',
      specs: [
        { k: 'Material', v: 'Recycled canvas + mesh' },
        { k: 'Capacity', v: 'Up to 6 kg' },
        { k: 'Weight', v: '1.4 kg' },
        { k: 'Foldable', v: 'Yes' },
      ],
      colors: [
        { id: 'sand', name: 'Sand', hex: '#D8C9A8' },
        { id: 'olive', name: 'Olive', hex: '#7D8466' },
        { id: 'ink', name: 'Ink', hex: '#1F1A14' },
      ],
    },
    {
      id: 6, title: 'Hearth Wool Throw', slug: 'hearth-wool-throw',
      price: 64, currency: 'USD',
      category: 'bed', pet: 'dog', rating: 4.8, stock: 25,
      images: [
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=cozy%20merino%20wool%20throw%20blanket%20folded%20on%20wooden%20chair%2C%20warm%20interior%2C%20lifestyle&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=dog%20sleeping%20on%20wool%20throw%20in%20front%20of%20fireplace%2C%20cozy%20evening&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=close%20up%20of%20merino%20wool%20weave%20texture%2C%20natural%20fiber%2C%20macro&image_size=square_hd',
      ],
      description: 'A throw that doubles as a dog bed liner. Naturally odor-resistant and warm.',
      specs: [
        { k: 'Material', v: '100% merino wool' },
        { k: 'Size', v: '120 x 80 cm' },
        { k: 'Care', v: 'Dry clean' },
      ],
      colors: [
        { id: 'rust', name: 'Rust', hex: '#B8553A' },
        { id: 'oat', name: 'Oat', hex: '#D8C9A8' },
        { id: 'pine', name: 'Pine', hex: '#3D5A4B' },
      ],
    },
    {
      id: 7, title: 'SmartSip Fountain', slug: 'smartsip-fountain',
      price: 79, currency: 'USD',
      category: 'smart', pet: 'cat', rating: 4.5, stock: 40,
      images: [
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=modern%20white%20pet%20water%20fountain%20with%20blue%20light%2C%20product%20photo%2C%20dark%20background&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=cat%20drinking%20from%20modern%20water%20fountain%2C%20lifestyle%20photo%2C%20warm%20light&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=disassembled%20view%20of%20pet%20water%20fountain%20showing%20filter%2C%20product%20detail&image_size=square_hd',
      ],
      badge: 'Smart',
      description: 'Circulates and filters 2L of water with ultra-quiet pump. Encourages cats to drink more, supporting kidney health.',
      specs: [
        { k: 'Capacity', v: '2 L' },
        { k: 'Power', v: 'USB-C, 5V' },
        { k: 'Filter', v: 'Activated carbon + ion exchange' },
      ],
    },
    {
      id: 8, title: 'Pawsh Puffer Jacket', slug: 'pawsh-puffer-jacket',
      price: 58, currency: 'USD',
      category: 'apparel', pet: 'dog', rating: 4.7, stock: 35,
      images: [
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=stylish%20orange%20puffer%20dog%20jacket%20on%20small%20dog%2C%20studio%20photo%2C%20product&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=small%20dog%20wearing%20puffer%20jacket%20walking%20in%20snow%2C%20lifestyle%20photo&image_size=square_hd',
        'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=detail%20of%20puffer%20jacket%20zipper%20and%20quilted%20fabric%2C%20macro%20photo&image_size=square_hd',
      ],
      description: 'Lightweight, water-resistant, and fully insulated. The elastic hem keeps warmth in without restricting movement.',
      specs: [
        { k: 'Material', v: 'Recycled polyester + down-alternative fill' },
        { k: 'Care', v: 'Machine wash cold' },
      ],
      colors: [
        { id: 'sunset', name: 'Sunset', hex: '#E07856' },
        { id: 'forest', name: 'Forest', hex: '#3D5A4B' },
        { id: 'graphite', name: 'Graphite', hex: '#4A5560' },
      ],
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
    },
  ],
  reviews: [
    { id: 1, product_id: 1, author: 'Mei L.', rating: 5, content: 'My cat refuses to leave this thing. Best purchase this year.', date: '2026-05-12' },
    { id: 2, product_id: 1, author: 'Jordan K.', rating: 5, content: 'Beautiful craftsmanship, smells like real wool (in a good way).', date: '2026-04-28' },
    { id: 3, product_id: 2, author: 'Sam P.', rating: 4, content: 'Leather is buttery soft. The brass clip is solid.', date: '2026-06-01' },
    { id: 4, product_id: 2, author: 'Anya R.', rating: 5, content: 'Develops a gorgeous patina after a few weeks.', date: '2026-05-20' },
  ],
};

// 默认金额格式化（USD）
export const money = (n) => Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(n);

async function tryFetch(url) {
  try {
    const r = await fetch(url, { headers: { 'Accept': 'application/json' } });
    if (!r.ok) return null;
    return await r.json();
  } catch (e) { return null; }
}

export async function fetchCategories() {
  const data = await tryFetch(ENDPOINTS.categories);
  if (data && data.code === 0) return data.data;
  return FALLBACK.categories;
}

export async function fetchProducts(params = {}) {
  const qs = new URLSearchParams(params).toString();
  const data = await tryFetch(`${ENDPOINTS.products}${qs ? '?' + qs : ''}`);
  if (data && data.code === 0) return data.data;
  // 过滤
  let items = FALLBACK.products.slice();
  if (params.category) items = items.filter(p => p.category === params.category);
  if (params.pet && params.pet !== 'all') items = items.filter(p => p.pet === params.pet);
  if (params.id) items = items.filter(p => String(p.id) === String(params.id));
  if (params.q) {
    const q = params.q.toLowerCase();
    items = items.filter(p => p.title.toLowerCase().includes(q) || p.description.toLowerCase().includes(q));
  }
  return { total: items.length, items };
}

export async function fetchProduct(id) {
  const r = await fetchProducts({ id });
  return r.items[0] || null;
}

export async function fetchReviews(productId) {
  return FALLBACK.reviews.filter(r => r.product_id === Number(productId));
}

export async function submitOrder(payload) {
  const r = await tryFetch(ENDPOINTS.order);
  // 真实请求
  try {
    const res = await fetch(ENDPOINTS.order, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    if (res.ok) return await res.json();
  } catch (e) {}
  // 回退：生成 mock 订单号
  return {
    code: 0,
    orderId: 'PP' + new Date().toISOString().slice(0,10).replace(/-/g,'') + Math.floor(Math.random()*9000+1000),
  };
}

export async function subscribeEmail(email) {
  try {
    const res = await fetch(ENDPOINTS.subscribe, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email }),
    });
    if (res.ok) return await res.json();
  } catch (e) {}
  return { code: 0, msg: 'subscribed' };
}

export { FALLBACK };
