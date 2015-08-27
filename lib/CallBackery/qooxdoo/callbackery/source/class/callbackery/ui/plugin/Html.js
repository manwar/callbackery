/* ************************************************************************
   Copyright: 2013 OETIKER+PARTNER AG
   License:   GPLv3 or later
   Authors:   Tobi Oetiker <tobi@oetiker.ch>
   Utf8Check: äöü
************************************************************************ */

/**
 * Abstract Visualization widget.
 */
qx.Class.define("callbackery.ui.plugin.Html", {
    extend : qx.ui.container.Composite,
    /**
     * create a page for the View Tab with the given title
     *
     * @param vizWidget {Widget} visualization widget to embedd
     */
    construct : function(cfg,getParentFormData) {
        this.base(arguments);
        this._cfg = cfg;
        this._loading = 0;
        this._getParentFormData = getParentFormData;
        this.setLayout(new qx.ui.layout.VBox(30));
        var html = this._html = new qx.ui.embed.Html().set({
            overflowX: "auto",
            overflowY: "auto",
            nativeContextMenu: true
        });
        this.add(html,{flex: 1});
        this.addListener('appear',this._loadData,this);
    },
    events: {
        actionResponse: 'qx.event.type.Data'
    },
    members: {
        _cfg: null,
        _loading: null,
        _getParentFormData: null,
        _html: null,
        _loadData: function(){
            var html = this._html;
            var cfg = this._cfg;
            var rpc = callbackery.data.Server.getInstance();
            this._loading++;
            var parentFormData = {};
            if (this._getParentFormData){
                parentFormData = this._getParentFormData();
            }
            var busy = callbackery.ui.Busy.getInstance();
            busy.show(this.tr('Loading Form Data'));
            var that = this;
            rpc.callAsync(function(data,exc){
                if (!exc){
                    html.setHtml(data);
                }
                else {
                    if (exc.code != 2){ /* 2 is for aborted calls, this happens when the popup is closed */
                        callbackery.ui.MsgBox.getInstance().exc(exc);
                    }
                }
                busy.hide();
                that._loading--;
            },'getPluginData',cfg.name,parentFormData);
        }
    }
});