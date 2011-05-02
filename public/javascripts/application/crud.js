dojo.provide("ib.crud");
ib.crud = {
  // variables {{{1
  connections: new Array,
  buttons: new Array,
  crudOverlay: dojo.create('div',{id:"crud_overlay"}),
  crudWindow: dojo.create('div',{id:"crud_window"}),
  // get {{{2
  get: function(node){
    var path = node.href;
    path = path.split('/').slice(-3).join('/');
    xhrArgs = {
      url: '/' + path,
      load: function(data){
        ib.crud.drawBox(data);
        dojo.attr('xhr_msg','class','hidden');
        ib.crud.connect_buttons();
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    dojo.publish('xhrMsg',['loading','info']);
    var deferred = dojo.xhrGet(xhrArgs);
  },
  put: function(node){
    var path = node.href;
    path = path.split('/').slice(-4).join('/');
    xhrArgs = {
      url: '/' + path,
      load: function(data){
        ib.crud.drawBox(data);
        dojo.attr('xhr_msg','class','hidden');
        ib.crud.connect_buttons();
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    dojo.publish('xhrMsg',['loading','info']);
    var deferred = dojo.xhrGet(xhrArgs);
  },
  // put {{{2
  //put: function(){
  //  xhrArgs = {
  //    form: dojo.query('form')[0],
  //    url: this.url.join('/'),
  //    load: function(data){
  //      dojo.publish('xhrMsg',['flash']);
  //      trst.task.drawBox(data);
  //    },
  //    error: function(error){
  //      dojo.publish('xhrMsg',['error','error',error]);
  //    }
  //  };
  //  var deferred = dojo.xhrPut(xhrArgs);
  //},
  // delete {{{2
  delete: function(node){
    var path = node.href;
    path = path.split('/').slice(-4,-1).join('/');
    xhrArgs = {
      url: '/' + path,
      load: function(data){
        dojo.publish('xhrMsg',['flash']);
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    var deferred = dojo.xhrDelete(xhrArgs);
    reload_path = node.getAttribute('data-referrer');
    ib.crud.reload(reload_path)
  },
  // reload the content{{{2
  reload: function(path){
    xhrArgs = {
      url: path,
      load: function(data){
        dojo.byId('xhr_content').innerHTML = data;
        dojo.attr('xhr_msg','class','hidden');
        ib.crud.connect();
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    var deferred = dojo.xhrGet(xhrArgs);
  },
  // position the taskWindow{{{2
  positionBox: function(o1,o2){
    var lastX,lastY,tskww,tskwh,
    base = dojo.position(o1),
    tskw = dojo.position(o2);
    lastX = base.x + 18;
    lastY = base.y + 18;
    dojo.style(o2,{
      left:   lastX + 'px',
      top:    lastY + 'px'
    });
  },
  // draw the taskWindow{{{2
  drawBox: function(data){
    if (dojo.query('[id^="crud"]').length == 0){
      var ovl = this.crudOverlay;
      var win = this.crudWindow;
      win.innerHTML = data;
      dojo.place(ovl,dojo.body(),'first');
      dojo.place(win,ovl,'after');
      this.positionBox(dojo.byId('xhr_content'),win);
    }
    else{
      dojo.destroy(dojo.byId('crud_window'))
      var ovl = dojo.byId('crud_overlay');
      var win = this.crudWindow;
      win.innerHTML = data;
      dojo.place(win,ovl,'after');
    }
  },
  // destroy the taskWindow and reset vars{{{2
  destroy: function(){
    dojo.query('[id^="crud"]').forEach("dojo.destroy(item)");
  },
  // connect actions in list{{{2
  connect: function(){
    dojo.forEach(this.connections, dojo.disconnect);
    this.connections.length = 0;
    //dojo.query('td.buttons_left > span > a').forEach(function(a){
    //  var verb = a.className;
    //  ib.crud.connections.push(
    //    dojo.connect(a, 'onclick', function(e){e.preventDefault();ib.crud[verb](e.target)}) 
    //  )
    //})
  },
  //// connect buttons in crudWindow{{{2
  connect_buttons: function(){
    dojo.forEach(this.buttons, dojo.disconnect);
    this.buttons.length = 0;
    dojo.query('td.buttons_bottom > span').forEach(function(span){
      if (dojo.hasClass(span,'put')){
        ib.crud.buttons.push(
          dojo.connect(span,'onclick', function(e){e.preventDefault(),ib.crud.not_ready('Edit')})
        )
      }
      else if(dojo.hasClass(span,'cancel')){
        ib.crud.buttons.push(
          dojo.connect(span, 'onclick', function(e){e.preventDefault(),ib.crud.destroy()})
        )
      }
      else if (dojo.hasClass(span,'delete')){
        ib.crud.buttons.push(
          dojo.connect(span,'onclick', function(e){e.preventDefault(),ib.crud.not_ready('Delete')})
        )
      }
      else if (dojo.hasClass(span,'post')){
        ib.crud.buttons.push(
          dojo.connect(span,'onclick', function(e){e.preventDefault(),ib.crud.not_ready('Create')})
        )
      }
      else{
        //
      }
    })
  },
  not_ready: function(msg){
    console.debug("Clicked");
    alert("Coming soon - " + msg + " - !");
  }
}
// initialize on load{{{2
function init(){
  ib.crud.connect();
}
dojo.ready(init);

