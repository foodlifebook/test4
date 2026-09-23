(()=>{
// Mirror Twins Android 1.1.0 online bridge
'use strict';
const SERVER='https://mt.grafixers.co.uk';
const button=document.getElementById('onlineBtn');
if(!button)return;
button.addEventListener('click',()=>{
  try{localStorage.setItem('mirrorTwinsLastMode','online')}catch(e){}
  button.disabled=true;
  button.classList.add('connecting');
  const label=button.querySelector('b');
  if(label)label.textContent='Connecting…';
  window.location.href=SERVER+'/?client=android&v=1.1.0';
});
const params=new URLSearchParams(window.location.search);
if(params.get('online')==='unavailable'){
  const note=document.getElementById('onlineStatus');
  if(note){
    note.textContent='Online Arena is unavailable right now. Solo mode still works offline.';
    note.classList.add('warn');
  }
}
})();
