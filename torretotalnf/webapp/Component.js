sap.ui.define(["sap/ovp/app/Component"], function (Component) {
	"use strict";

	// App Overview Page "puro manifest": não tem view/controller próprios,
	// tudo (filtros globais e cards) vem da seção "sap.ovp" do manifest.json.
	return Component.extend("nstorretotalnf.torretotalnf.Component", {
		metadata: {
			manifest: "json"
		}
	});
});
