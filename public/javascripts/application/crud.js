dojo.require("dojo.data.ItemFileReadStore")
dojo.require("dijit.form.FilteringSelect")
dojo.provide("ib.crud");
ib.crud = {
  // variables {{{1
  connections: new Array,
  buttons: new Array,
  search_ary: new Array,
  timer: 0,
  associate: false,
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
  // edit
  edit: function(node){
    this.associate = node.href.split('/').slice(-3,-2).toString() == 'associations'
    if (this.associate)
      this.search_ary = node.href.split('/').slice(-2)
    var path = node.href;
    path = path.split('/').slice(-4).join('/');
    xhrArgs = {
      url: '/' + path,
      load: function(data){
        ib.crud.drawBox(data);
        if (ib.crud.associate)
          ib.crud.search(ib.crud.search_ary);
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
  put: function(node){
    var path = node.action
    if (this.associate){
      path = path.split('/').slice(-5,-1).join('/');
      this.associate = false;
    }else{
      path = path.split('/').slice(-4,-1).join('/');
    }
    xhrArgs = {
      form: node,
      url:'/' + path,
      load: function(data){
        dojo.publish('xhrMsg',['flash']);
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    var deferred = dojo.xhrPut(xhrArgs);
    ib.crud.destroy();
    reload_path = node.getAttribute('data-referrer');
    ib.crud.reload(reload_path)
  },
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
    ib.crud.destroy();
    reload_path = node.getAttribute('data-referrer');
    ib.crud.reload(reload_path)
  },
  // new {{{2
  new: function(node){
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
    var deferred = dojo.xhrGet(xhrArgs);
    ib.crud.destroy();
  },
  post: function(node){
    var path = node.action
    path = path.split('/').slice(-3).join('/');
    xhrArgs = {
      form: node,
      url:'/' + path,
      load: function(data){
        dojo.publish('xhrMsg',['flash']);
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    var deferred = dojo.xhrPost(xhrArgs);
    ib.crud.destroy();
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
        var isLoop = dojo.query('span.reload')[0];
        if (isLoop){
          dojo.addClass(isLoop,'active')
          isLoop.setAttribute('title','Stop Auto-Reload')
        }
        ib.crud.connect();
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    var deferred = dojo.xhrGet(xhrArgs);
  },
  auto_reload: function(node){
    var path = node.getAttribute('data-referrer');
    var duration = node.getAttribute('data-duration');
    if (dojo.hasClass(node,'active')){
      dojo.removeClass(node,'active')
      node.setAttribute('title','Start Auto-Reload')
      clearInterval (this.timer)
      dojo.publish('xhrMsg',['monitor.auto_reload_stop','info'])
    }else{
      dojo.addClass(node,'active')
      node.setAttribute('title','Stop Auto-Reload')
      this.timer = setInterval ("ib.crud.reload('" + path + "')",duration);
      dojo.publish('xhrMsg',['monitor.auto_reload_start','info'])
    }
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
    if (this.search_ary.length > 0) {
      this.search_ary.forEach(function(d){
        if (dijit.byId(d) != undefined)
        dijit.byId(d).destroyRecursive()
      });
      this.search_ary.length = 0;
    }
  },
  // connect actions in list{{{2
  connect: function(){
    dojo.forEach(this.connections, dojo.disconnect);
    this.connections.length = 0;
    dojo.query('#menu ul > li > a.edit,td.buttons_left > span > a,td.last_row > span > a').forEach(function(a){
      var verb = a.className;
      ib.crud.connections.push(
        dojo.connect(a, 'onclick', function(e){e.preventDefault();ib.crud[verb](e.target)})
      )
    })
    var isLoop = dojo.query('span.reload')[0];
    if (isLoop)
      dojo.connect(isLoop,'onclick',function(e){ib.crud.auto_reload(e.target)})
  },
  //// connect buttons in crudWindow{{{2
  connect_buttons: function(){
    dojo.forEach(this.buttons, dojo.disconnect);
    this.buttons.length = 0;
    dojo.query('td.buttons_bottom > span > a').forEach(function(a){
      var verb = a.className;
      ib.crud.connections.push(
        dojo.connect(a, 'onclick', function(e){e.preventDefault();ib.crud[verb](e.target)})
      )
    })
    dojo.query('td.buttons_bottom > input').forEach(function(a){
      var verb = a.className;
      ib.crud.connections.push(
        dojo.connect(a, 'onclick', function(e){e.preventDefault();ib.crud[verb](e.target.form)})
      )
    })
  },
  not_ready: function(msg){
    alert("Coming soon - " + msg + " - !");
  },
  search: function(ary,filter){
    this.search_ary = ary
    var what_store = new dojo.data.ItemFileReadStore({
      url: "/utils/search/" + ary[0] + "/" + ary[1]
    });
    var what_select = new dijit.form.FilteringSelect({
      id: ary[0],
      name: "what_id",
      value: "",
      store: what_store,
      searchAttr: "name",
      queryExpr: "*${0}*",
      highlightMatch: "all",
      searchDelay: 500,
      labelAttr: "label",
      placeHolder: "Select " + ary[0].split('_')[1],
      onChange: function(id){
        ib.crud.on_select(ary,id)
      }
    },ary[0]);
  },
//
on_select: function(ary,id){
    var submit_button = dojo.query("td.buttons_bottom > input")[0]
    var render_partial = function(ary,id,ss){
      xhrArgs = {
        url: "/utils/search/" + ary[0] + "/" + id + "/" + ary[1],
        load: function(data){
          dojo.byId('xhr_partial').innerHTML = data;
          if (ss){
            with_input(ary,id);
          }
          submit_button.removeAttribute("disabled")
          dojo.attr('xhr_msg','class','hidden');
        },
        error: function(error){
          dojo.publish('xhrMsg',['error','error',error]);
        }
      };
      var deferred = dojo.xhrGet(xhrArgs);
    };
    var with_input = function(ary,id){
      for (i=1;i<ary.length;i++){
        var with_store = new dojo.data.ItemFileReadStore({
          url: "/utils/search/" + ary[i].split('_').slice(-2).join('_') + "/" + ary[0]
        });
        if (dijit.byId(ary[i]))
          dijit.byId(ary[i]).destroy();
        var with_select = new dijit.form.FilteringSelect({
          id: ary[i],
          name: "with_id",
          value: "",
          store: with_store,
          searchAttr: "name",
          placeHolder: "Select " + ary[i].split('_')[ary[i].split('_').length - 1],
          labelAttr: "label",
          labelType: "html"
        },ary[i]);
        if (ary.some(function(e){return e.search(/permission/) >=0 })){
          ib.crud.search_ary.push(ary[i])
          var current_id = ary[i].split('_')
          current_id.length > 2 ? current_id.splice(1,1) : current_id.splice(0,1)
          // normal set function does not change the hidden inputs name attr.
          // probably dojo bug
          //with_select.set("name","[with_id][" + ary[0] + "]")
          var current_name = dojo.query('[type="hidden"]',with_select.domNode)[0]
          dojo.attr(current_name,"name","[with_id][" + ary[i] .split('_').join('_') + "][" + current_id.join('_') + "]")
          current_id.push('id')
          current_id = current_id.join('_')
          with_select.set("value",dijit.byId("persons_permission").item[current_id]);
        }
      }
    };
    if (ary.every(function(e){return e.search(/owner|group/) >= 0})){
      //many_to_many
      render_partial(ary,id,true)
    }else if (ary.some(function(e){return e.search(/permission/) >=0 })){
      ary = ["persons_permission","persons_group","request_hw_node","request_hw_reader","response_hw_node","response_hw_device"]
        render_partial(ary,id,true)
    }else{
      //one_to_many
      render_partial(ary,id,true)
    }
  }
}
// initialize on load{{{2
function init(){
  ib.crud.connect();
}
dojo.ready(init);

