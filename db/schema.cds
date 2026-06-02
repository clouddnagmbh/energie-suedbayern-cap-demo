using {
    cuid,
    managed,
} from '@sap/cds/common';

namespace my.ecommerce;

entity Products : cuid, managed {
    name        : String;
    description : String;
    price       : Decimal(10, 2);
    reviews     : Association to many Reviews
                      on reviews.product = $self;
}

entity Reviews : cuid, managed {
    title   : String;
    comment : String;
    rating  : Integer @assert.range: [
        1,
        5
    ];
    product : Association to Products;
}
