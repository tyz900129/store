// main.js · 入口：挂载 header / footer / 购物车徽标
import { mountHeader, mountFooter, updateCartBadge, bindAddToCart, toast } from './ui.v4.js';

// 根据 body data-page 设置 active
const page = document.body.dataset.page || 'home';
mountHeader(page);
mountFooter();
updateCartBadge();
bindAddToCart();

// 跨页面购物车变化
window.addEventListener('cart:change', updateCartBadge);
window.addEventListener('storage', updateCartBadge);
