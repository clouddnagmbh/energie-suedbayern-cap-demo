using my.ecommerce as db from '../db/schema';

// =============================================================================
// Im eigenen Modell: Berechtigungen mit @requires & @restrict
// =============================================================================
//
//  @requires  -> Wer darf überhaupt hinein? (angemeldet sein oder Rolle haben)
//  @restrict  -> Welche Aktion (READ / WRITE) ist für welche Rolle erlaubt?
//
//  Rollen in dieser Demo:
//    - Viewer : darf Produkte und Reviews nur LESEN
//    - Admin  : darf alles (lesen, anlegen, ändern, löschen)
//
//  Rollennamen ("Viewer", "Admin") sind frei wählbar.
//  Wichtig ist nur, dass sie überall gleich heißen:
//    1) hier in @restrict ... to: 'Viewer' / 'Admin'
//    2) bei den Test-Nutzern (package.json -> auth.users.*.roles)  [mocked]
//    3) in der xs-security.json (role-templates)                   [xsuaa]
// =============================================================================

service ProductCatalog @(requires: 'authenticated-user') {

    // Viewer: nur lesen
    // Admin: alles ('*' = READ + CREATE + UPDATE + DELETE)
    // @odata.draft.enabled: aktiviert den Fiori-Bearbeiten-/Anlegen-Flow (Entwurfsmodus)
    entity Products @(
        odata.draft.enabled,
        restrict: [
            {
                grant: 'READ',
                to   : 'Viewer'
            },
            {
                grant: '*',
                to   : 'Admin'
            }
        ]
    ) as projection on db.Products;

    // Viewer: lesen
    // Admin: voller Zugriff
    // Zusätzlich: jeder angemeldete Nutzer darf SEINE EIGENEN Reviews bearbeiten
    // -> instanzbasierte Berechtigung über  where: createdBy = $user
    entity Reviews @(restrict: [
        {
            grant: 'READ',
            to   : 'Viewer'
        },
        {
            grant: '*',
            to   : 'Admin'
        },
        {
            grant: '*',
            to   : 'authenticated-user',
            where: 'createdBy = $user'
        }
    ]) as projection on db.Reviews;
}
