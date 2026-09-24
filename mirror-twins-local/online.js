(()=>{
// Mirror Twins Android permanent updater bridge v2
'use strict';
const SERVER='https://mt.grafixers.co.uk';

const button=document.getElementById('onlineBtn');
if(button){
  button.addEventListener('click',()=>{
    try{localStorage.setItem('mirrorTwinsLastMode','online')}catch(e){}
    button.disabled=true;
    button.classList.add('connecting');
    const label=button.querySelector('b');
    if(label)label.textContent='Connecting…';
    window.location.href=SERVER+'/?client=android&v=2.0.0';
  });
}

const params=new URLSearchParams(window.location.search);
if(params.get('online')==='unavailable'){
  const note=document.getElementById('onlineStatus');
  if(note){
    note.textContent='Online Arena is unavailable right now. Solo mode still works offline.';
    note.classList.add('warn');
  }
}

const updateBtn=document.getElementById('checkUpdatesBtn');
const versionText=document.getElementById('updateVersionText');
if(window.NativeUpdater){
  try{
    if(versionText){
      versionText.textContent='Game: '+NativeUpdater.getGameVersion()+' · App: '+NativeUpdater.getAppVersion();
    }
  }catch(e){}
  if(updateBtn){
    updateBtn.addEventListener('click',()=>{
      try{NativeUpdater.checkForUpdates()}catch(e){}
    });
  }
}else if(updateBtn){
  updateBtn.disabled=true;
  updateBtn.textContent='Updates available in Android app';
}
})();
