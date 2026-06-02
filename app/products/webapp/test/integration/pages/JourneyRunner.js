sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"my/ecommerce/products/test/integration/pages/ProductsList",
	"my/ecommerce/products/test/integration/pages/ProductsObjectPage",
	"my/ecommerce/products/test/integration/pages/ReviewsObjectPage"
], function (JourneyRunner, ProductsList, ProductsObjectPage, ReviewsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('my/ecommerce/products') + '/test/flp.html#app-preview',
        pages: {
			onTheProductsList: ProductsList,
			onTheProductsObjectPage: ProductsObjectPage,
			onTheReviewsObjectPage: ReviewsObjectPage
        },
        async: true
    });

    return runner;
});

