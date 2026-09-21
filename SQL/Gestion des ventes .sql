
==================================================
-- 1. Vérification et Contrôle Qualité des Données
==================================================


-- 1.1 Vérifier les datasets

select count(*) from Transactions;
select count(*) from Categorie_Produits;
select count(*) from Fournisseur;
select count(*) from Produits;
select count (*) from Magasins;

-- 1.2 Top 10 for each table

select top 10 * from Transactions;
select top 10 * from Categorie_Produits;
select top 10 * from Fournisseur;
select top 10 * from Produits;
select top 10 * from Magasins;


-- 1.3 Vérifier l'état de toutes les colonnes clés : 

select table_name, column_name, data_type, character_maximum_length, is_nullable
from INFORMATION_SCHEMA.COLUMNS
where ( table_name = 'Fournisseur' AND column_name ='Fournisseur_id')
or ( table_name = 'Produits' AND column_name ='Produit_SKU')
or( table_name = 'Categorie_Produits' AND column_name ='Category_id')
or( table_name = 'Magasins' AND column_name ='magasin_id')
or( table_name = 'Transactions' AND column_name ='transaction_id');

-- 1.4 Correction des contraintes NOT NULL

SELECT COUNT(*) FROM Categorie_Produits WHERE Category_id IS NULL;
SELECT COUNT(*) FROM Magasins WHERE magasin_id IS NULL;
SELECT COUNT(*) FROM Produits WHERE Produit_SKU IS NULL;
SELECT COUNT(*) FROM Transactions WHERE transaction_id IS NULL;




ALTER TABLE Categorie_Produits ALTER COLUMN Category_id VARCHAR(20) NOT NULL;
ALTER TABLE Magasins ALTER COLUMN magasin_id VARCHAR(20) NOT NULL;
ALTER TABLE Produits ALTER COLUMN Produit_SKU VARCHAR(20) NOT NULL;
ALTER TABLE Transactions ALTER COLUMN transaction_id INT NOT NULL;





--================================
-- 3.Creation des relationships : 
--=================================


-- 3.1 Clés Primaires : 

alter table Fournisseur add constraint PK_Fournisseur primary key (Fournisseur_id);
alter table Categorie_Produits add constraint PK_Categorie_Produits primary key (Category_id);
alter table Produits add constraint PK_Produits primary key (Produit_SKU);
alter table Magasins add constraint PK_Magasins primary key (magasin_id);
alter table Transactions add constraint PK_Transactions primary key (transaction_id);

-- 3.1 Clés Etrangères :

alter table Produits 
add constraint FK_Produits_Fournisseur foreign key (Fournisseur_id)
references Fournisseur(Fournisseur_id);

alter table Produits
add constraint FK_Produits_Categorie foreign key (Category_id)
references Categorie_Produits(Category_id);

alter table Transactions 
add constraint FK_Transactions_Produits foreign key (Produit_SKU)
references Produits(Produit_SKU);

alter table Transactions 
add constraint FK_Transactions_Magasins foreign key (magasin_id)
references Magasins(magasin_id);

-- 3.3 Vérification finale : 

SELECT 
    fk.name AS Nom_Contrainte,
    tp.name AS Table_Enfant,
    cp.name AS Colonne_FK,
    tr.name AS Table_Parent,
    cr.name AS Colonne_PK
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
INNER JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
INNER JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
ORDER BY tp.name;


===================================
-- 3. Analyse et Requêtes Métier
===================================


select 
    t.transaction_id,
    t.Date,
    p.Produit_designation,
    m.Ville,
    m.Region,
    t.Quantite,
    t.Ventes
from Transactions t 
inner join Produits p 
    on t.Produit_SKU = p.Produit_SKU
inner join Magasins m 
    on t.magasin_id = m.magasin_id;


select 
    t.transaction_id,
    t.Date,
    p.Prix_vente,
    t.Quantite,
    t.Prix_Vente
from Transactions t
inner join Produits P
    ON t.Produit_SKU = p.Produit_SKU;



select
    t.transaction_id,
    t.Date,
    m.Region,
    c.Product_Category,
    f.Fournisseur_Nom
FROM Transactions t
INNER JOIN Magasins m 
    ON t.magasin_id = m.magasin_id
INNER JOIN Produits p 
    ON t.Produit_SKU = p.Produit_SKU
INNER JOIN Categorie_Produits c 
    ON p.Category_id = c.Category_id
INNER JOIN Fournisseur f 
    ON p.Fournisseur_id = f.Fournisseur_id;



    select 
        t.transaction_id,
        t.Date,
        m.Ville,
        c.Product_Category,
        f.Fournisseur_Nom 

    from Transactions t
     inner join Magasins m
    on t.magasin_id = m.magasin_id
    inner join Produits p
    on t.Produit_SKU = p.Produit_SKU
    inner join Categorie_Produits c
    on p.Category_id = c.Category_id
    inner join Fournisseur f
    on p.fournisseur_id = f.fournisseur_id;


    select 
         p.Produit_designation,
         p.Prix_Achat,
         p.Prix_vente,
         c.Product_Category
    From Produits p
    inner join Categorie_Produits c
    on p.Category_id = c.Category_id;



    select c.Product_Category , sum(t.Ventes) as total_Ventes 
    from Transactions t 
    INNER JOIN Produits p 
    ON t.Produit_SKU = p.Produit_SKU
    INNER JOIN Categorie_Produits c 
    on p.Category_id = c.Category_id 
    GROUP BY c.Product_Category
    order by total_Ventes desc;

    
    select 
        t.transaction_id,
        t.Date,
        p.Prix_Achat,
        P.Prix_vente,
        t.Prix_Vente,
        t.Quantite,
        t.Ventes
    from Transactions t 
    inner join Produits p
    on t.Produit_SKU = p.Produit_SKU;




    select
        t.transaction_id,
        t.Date,
        m.Ville,
        p.Prix_Achat,
        c.Product_Category,
        f.Fournisseur_Nom
    from Transactions t
    inner join Produits p
    on t.Produit_SKU = p.Produit_SKU
    inner join Magasins m
    on t.magasin_id = m.Magasin_id
    inner join Fournisseur f
    on p.Fournisseur_id = f.Fournisseur_id
    inner join Categorie_Produits c
    on p.Category_id = c.Category_id;



    select c.Product_Category , sum(Ventes) as total_ventes
    from Transactions t
    inner join Produits p
    on t.Produit_SKU = p.Produit_SKU 
    inner join Categorie_Produits c
    on p.Category_id = c.Category_id
    group by c.Product_Category order by total_ventes desc



    select * from Transactions;


     select
        t.transaction_id,
        t.Prix_Vente,
        p.Prix_vente
    from Transactions t
    inner join Produits p
    on t.Produit_SKU = p.Produit_SKU

    -- Quel est le chiffre d'affaires total (Ventes) toutes transactions confondues ?

    select sum(ventes) as chiffre_affaire from Transactions;

    -- Quelle est la transaction avec le montant de vente le plus élevé ? 

    select top 1 transaction_id, Date, Produit_SKU , ventes from Transactions order by Ventes desc;

    -- Montant moyen d'une transaction

    select avg(ventes) as Montant_Moyen from Transactions;

    -- Quels sont les 10 Categorie des produits qui génèrent le plus de chiffre d'affaires ?

    select top 10 c.Product_Category, sum(ventes) as chiffre_affaire
    from Transactions t
    inner join Produits p
    on t.Produit_SKU = p.Produit_SKU
    inner join Categorie_Produits c
    on p.Category_id = c.Category_id
    group by c.Product_Category order by chiffre_affaire desc;

   --Quelle catégorie de produit a la meilleure marge moyenne (Prix_vente - Prix_Achat) ?

   select top 10 c.Product_Category, AVG(P.Prix_Vente - P.Prix_Achat) as Marge_Moyen 
    from Transactions t
    inner join Produits p
    on t.Produit_SKU = p.Produit_SKU
    inner join Categorie_Produits c
    on p.Category_id = c.Category_id
    group by c.Product_Category order by Marge_Moyen desc;

   --Quels produits n'ont jamais été vendus (aucune transaction associée) ?

   select p.Produit_SKU, p.Produit_Designation 
   from Produits p
   left join Transactions t 
    on p.Produit_SKU = t.Produit_SKU
   where t.transaction_id IS NULL;

   --Quelle région génère le plus de chiffre d'affaires total ?

   select top 1 m.Region, sum(t.ventes) as chiffre_affaire
   from Magasins m
   left join Transactions t
   on m.magasin_id = t.magasin_id
   group by m.Region order by chiffre_affaire desc;

   --Quel est le nombre de transactions par ville, trié du plus élevé au plus faible ?

    select m.Ville, count(t.transaction_id) as N_Transactions
   from Magasins m
   left join Transactions t
   on m.magasin_id = t.magasin_id
   group by Ville order by N_Transactions desc;

   --Quels magasins n'ont enregistré aucune vente (0 transaction) ?

   select m.magasin_id from Magasins m
   left join Transactions t
   on m.magasin_id = t.magasin_id 
   where t.transaction_id is NULL;

   --Quel fournisseur génère le plus de chiffre d'affaires à travers tous ses produits ?

   select f.Fournisseur_Nom , sum(t.Ventes) as chiffre_Affaire
   from Fournisseur f
   left join Produits p
   on f.Fournisseur_id = P.Fournisseur_id
   left join Transactions t
   on p.Produit_SKU = t.Produit_SKU
   group by f.Fournisseur_Nom order by chiffre_Affaire desc;

    select f.Fournisseur_Nom , sum(t.Ventes) as chiffre_Affaire
   from Transactions t
   inner join Produits p
   on t.Produit_SKU = p.Produit_SKU
   inner join Fournisseur f
   on P.Fournisseur_id = f.Fournisseur_id
   group by f.Fournisseur_Nom order by chiffre_Affaire desc;

   --Quels fournisseurs proposent des produits dans plus de 5 catégories différentes ?

   select f.Fournisseur_Nom , count(distinct p.Category_id) as NB_Categories 
   from Produits p
   inner join Fournisseur f
   on p.Fournisseur_id = f.Fournisseur_id
   group by f.Fournisseur_Nom having count(distinct p.Category_id) > 5;

   --Quel est le chiffre d'affaires total par mois (toute l'année confondue) ?

   select month(Date) as Mois , sum(Ventes) as CA from Transactions
   group by month(Date) order by Mois;

   --Quel jour de la semaine génère le plus de ventes en moyenne ?

   select datename(WEEKDAY, Date) as semaine , avg(Ventes) as vente_moyen
   from Transactions group by datename(WEEKDAY, Date) order by vente_moyen desc;

   --Compare le chiffre d'affaires du premier semestre (Jan-Juin) vs le second semestre (Juil-Déc)

   select case when month(Date) <= 6 then 's1' else 's2'end , sum(Ventes) as ca
   from Transactions group by case when month(Date) <= 6 then 's1' else 's2'end;

   --Pour chaque catégorie, quel est le produit le plus vendu (en quantité) ?

    WITH VentesParProduit AS (
    SELECT 
        c.Product_Category,
        p.Produit_designation,
        SUM(t.Quantite) AS Total_Quantite,
        ROW_NUMBER() OVER (PARTITION BY c.Product_Category ORDER BY SUM(t.Quantite) DESC) AS Rang
    FROM Transactions t
    INNER JOIN Produits p ON t.Produit_SKU = p.Produit_SKU
    INNER JOIN Categorie_Produits c ON p.Category_id = c.Category_id
    GROUP BY c.Product_Category, p.Produit_designation
     )
    SELECT Product_Category, Produit_designation, Total_Quantite
    FROM VentesParProduit
    WHERE Rang = 1
    order by Total_Quantite desc;

   --Quels magasins ont un chiffre d'affaires supérieur à la moyenne de leur région ?

    WITH CA_Magasin AS (
    SELECT m.magasin_id, m.Ville, m.Region, SUM(t.Ventes) AS CA
    FROM Transactions t
    INNER JOIN Magasins m ON t.magasin_id = m.magasin_id
    GROUP BY m.magasin_id, m.Ville, m.Region
     ),
    CA_Region AS (
    SELECT Region, AVG(CA) AS CA_Moyen_Region
    FROM CA_Magasin
    GROUP BY Region
     )
    SELECT cm.Ville, cm.Region, cm.CA, cr.CA_Moyen_Region
    FROM CA_Magasin cm
    INNER JOIN CA_Region cr ON cm.Region = cr.Region
    WHERE cm.CA > cr.CA_Moyen_Region
    ORDER BY cm.Region, cm.CA DESC;

    --Quelle est la part (%) que représente chaque catégorie dans le chiffre d'affaires total ?

    SELECT 
    c.Product_Category,
    SUM(t.Ventes) AS CA_Categorie,
    ROUND(SUM(t.Ventes) * 100.0 / SUM(SUM(t.Ventes)) OVER (), 2) AS Pourcentage
    FROM Transactions t
    INNER JOIN Produits p ON t.Produit_SKU = p.Produit_SKU
    INNER JOIN Categorie_Produits c ON p.Category_id = c.Category_id
    GROUP BY c.Product_Category
    ORDER BY CA_Categorie DESC;








   

    

