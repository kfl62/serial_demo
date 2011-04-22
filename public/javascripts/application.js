var sysMsg = dojo.subscribe('xhrMsg',function(what,kind,data){
  var p = what;
  kind ? p += '/' + kind : p += '/info'
  data ? p += '?data=' + data : p += ''
  var info_node = dojo.byId('xhr_msg'),
      anim = dojo.animateProperty({
        node: info_node,
        duration: 1000,
        properties:{
          opacity: {end: 0, start: 1}
        },
        onEnd: function(){
          dojo.attr(info_node,'class','hidden');
        }
      });
  dojo.xhrGet({
    handleAs: 'json',
    url: '/utils/msg/' + p,
    load: function(data){
      if (data){
        info_node.innerHTML = data.msg.txt;
        dojo.attr(info_node,'class',data.msg.class);
        dojo.style(info_node,{'opacity': 1});
        if (what != "loading")
          anim.play(2000);
      }
    }
  });
})

function init(){
  dojo.require('ibttn.auth');
  dojo.publish('xhrMsg',['flash']);
}
dojo.ready(init);