/* ************************************************************************
   Copyright: 2011 OETIKER+PARTNER AG
   License:   GPLv3 or later
   Authors:   Tobi Oetiker <tobi@oetiker.ch>
   Utf8Check: äöü
************************************************************************ */
/**
 * Build the desktop. This is a singleton. So that the desktop
 * object and with it the treeView and the searchView are universaly accessible
 */
qx.Class.define("callbackery.ui.Desktop", {
    extend : qx.ui.container.Composite,
    type : 'singleton',

    construct : function() {
        this.base(arguments,new qx.ui.layout.VBox());
        this.set({
            padding: [5,10,0,10]
        });

        this.add(callbackery.ui.Header.getInstance());
        this.add(callbackery.ui.TabView.getInstance(),{ flex: 1})
        this.add(callbackery.ui.Footer.getInstance());
    }
});