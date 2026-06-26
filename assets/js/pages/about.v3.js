// pages/about.js
import { icon } from '../ui.v2.js';
// 静态内容；如需动态可从 data.js 注入
const values = [
  { num: '01', title: 'Made by hand', body: 'Every product is hand-finished in our Brooklyn studio by a small team of craftspeople. No mass production, no shortcuts.' },
  { num: '02', title: 'Natural materials', body: 'We choose wool, leather, ceramic, and recycled fibers over plastic. Better for pets, better for the planet.' },
  { num: '03', title: 'Forever guarantee', body: 'If anything we make ever fails, we will repair or replace it. No questions, no expiration date.' },
];
const team = [
  { name: 'Maya Okafor', role: 'Founder & Designer' },
  { name: 'Tomás Reyes', role: 'Head of Craft' },
  { name: 'Lia Park', role: 'Customer Care' },
  { name: 'Ben Cho', role: 'Operations' },
];
const valEl = document.getElementById('values');
if (valEl) valEl.innerHTML = values.map(v => `
  <div class="value">
    <div class="num">${v.num}</div>
    <h3>${v.title}</h3>
    <p>${v.body}</p>
  </div>
`).join('');
const teamEl = document.getElementById('team');
if (teamEl) teamEl.innerHTML = team.map(m => `
  <div class="member">
    <div class="pic">
      <img src="https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=portrait%20of%20${encodeURIComponent(m.name)}%2C%20friendly%20smile%2C%20natural%20light%2C%20warm%20tones%2C%20editorial%20portrait&image_size=square" alt="${m.name}">
    </div>
    <h4>${m.name}</h4>
    <div class="role">${m.role}</div>
  </div>
`).join('');
