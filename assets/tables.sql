CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    display_name TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE stores (
    id BIGSERIAL PRIMARY KEY,
    owner_user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    store_id BIGINT REFERENCES stores(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    visible BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    metadata JSONB DEFAULT '{}'
);

CREATE TABLE product_variants (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE,
    sku TEXT NOT NULL,
    title TEXT,          
    price_cents BIGINT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'USD',
    active BOOLEAN NOT NULL DEFAULT true,
    attributes JSONB DEFAULT '{}' , 
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (sku)
);

CREATE TABLE inventory (
    id BIGSERIAL PRIMARY KEY,
    variant_id BIGINT REFERENCES product_variants(id) ON DELETE CASCADE,
    location_id INT DEFAULT 0,
    quantity INT NOT NULL DEFAULT 0,
    reserved INT NOT NULL DEFAULT 0, 
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (variant_id, location_id)
);


CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    store_id BIGINT REFERENCES stores(id), 
    total_cents BIGINT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'USD',
    status TEXT NOT NULL, 
    shipping_address JSONB,
    billing_address JSONB,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE,
    variant_id BIGINT REFERENCES product_variants(id),
    quantity INT NOT NULL,
    unit_price_cents BIGINT NOT NULL,
    total_price_cents BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES orders(id) ON DELETE SET NULL,
    provider TEXT NOT NULL, 
    provider_payment_id TEXT,
    amount_cents BIGINT NOT NULL,
    status TEXT NOT NULL, 
    raw_payload JSONB,    
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE role_permissions (
    role_id INT REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INT REFERENCES permissions(id) ON DELETE CASCADE, 
    PRIMARY KEY(role_id, permission_id)
);

CREATE TABLE user_roles (
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    role_id INT REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY(user_id, role_id)
);

CREATE TABLE idempotency_keys (
    id BIGSERIAL PRIMARY KEY,
    key TEXT UNIQUE NOT NULL,
    user_id BIGINT,
    request_hash TEXT,
    response_code INT,
    response_body JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL
);

INSERT INTO users (username, email, password_hash, display_name) VALUES ('wbudleigh0', 'wbudleigh0@tinyurl.com', '$2a$04$38UTy4i1b0EDyd2Fha.EgezSjWc.ygK5t0P6d/OdxQNKiGYjKV5S2', 'Way Budleigh');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('gwardingly1', 'gwardingly1@usnews.com', '$2a$04$n3PnGH6cZCmE5fUtvSBvaOsEVMDIGOL3P9d0OgMAmJw/wfMo1c7oW', 'Gordie Wardingly');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('psellick2', 'psellick2@sphinn.com', '$2a$04$Th1kVAsmCzybRtB700SJV.JqogYYQfeD25.GfUghtgd6rV74xeVIa', 'Priscilla Sellick');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('iwiddowfield3', 'iwiddowfield3@indiatimes.com', '$2a$04$PTRwVahaKkIwL1Vlmtm4Zeni/.Mf0M1FnZ.36XDS/m1qbBCETWtQS', 'Irita Widdowfield');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('cahmed4', 'cahmed4@bizjournals.com', '$2a$04$BOg2w7vBAmV3f9CKjR84Deq6BcdelLx8MrC4v88xUXqPnycxq.hkS', 'Charlton Ahmed');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('gboar5', 'gboar5@ihg.com', '$2a$04$OpaLmuXPORl1VO5gWAEHIeFiB2HYgq.8k1Um9wb8lWkR0bLwgadWi', 'Giorgi Boar');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('acrichten6', 'acrichten6@wufoo.com', '$2a$04$eSNQJAqRiBvqNHGAz0Fnquol5agwv96rF8h9YJtHWHPCg/WVKnMAW', 'Arleyne Crichten');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('mspink7', 'mspink7@miitbeian.gov.cn', '$2a$04$hElZJ4g0dXYtuBHVqlWs6ul/JwHktaEeQVLvXFBPUPZk/iC8kYbUi', 'Mahmud Spink');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('gcapstaff8', 'gcapstaff8@de.vu', '$2a$04$qiLtBKgRTGcJ9oA41RIpiO0U6yDRFzZBYs1F199XNb/6YQ4viZz/e', 'Gil Capstaff');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('spiris9', 'spiris9@nasa.gov', '$2a$04$1w.4vTu563raSGdDK7WkFuuvF99TVZA5P4lG91OpMp.mFVQIdCh4W', 'Stefania Piris');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('wocrianea', 'wocrianea@intel.com', '$2a$04$H5Rmr20rDa2Dw601ia7uweYUmuk8Tpz5HaUg4ZRpp.Qe7l/iyQ0NS', 'Wilmar O''Criane');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('fdumberrillb', 'fdumberrillb@gov.uk', '$2a$04$KQfn98cBtEw8RfrvJpCnC.r.tKmpAq1o4XgxkH1ltj803xheYoVse', 'Farly Dumberrill');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('estoppardc', 'estoppardc@vk.com', '$2a$04$wlh7VHd0A6xAoAzm0DGlpObd9tBQaGiRl./QQsfQGePd6kInqkqZK', 'Erasmus Stoppard');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('jfellgettd', 'jfellgettd@home.pl', '$2a$04$JgmYnPE1WkAwRNmrunsaAuhvwfRVjza3F4VjVRb54tnRUiiXYbQtG', 'Jeri Fellgett');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('wworsnape', 'wworsnape@elegantthemes.com', '$2a$04$fYtEapvbhJtdaUZ4OceylO9FAVYhtY/.9ptSk2Vz.yp5DM9kEXf0S', 'Willis Worsnap');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('jlef', 'jlef@bluehost.com', '$2a$04$vRyjYjd2z9lpqh6BNypjK.GUOyP9W4JBA/ZY7r1oDNR79zGim54Ee', 'Jamill Le Franc');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('inelliesg', 'inelliesg@engadget.com', '$2a$04$VEFg1TlGXBV.DIOg5UH2vOA49ykYagqOrgeDe1FuLZvxlu2Vh6mi6', 'Ingemar Nellies');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('dnottih', 'dnottih@sohu.com', '$2a$04$vEmEkKRx4MizZpObkrB2SOK9XSmJpY/JxffPHvlLIryH5BgtQ09vi', 'Darice Notti');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('dmidneri', 'dmidneri@over-blog.com', '$2a$04$3tkUwRdcFsiM3mTvR5Q6Q.oxyqPnNgG/wt34czzcye71ElV1LaoPa', 'Dall Midner');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('dhovertj', 'dhovertj@delicious.com', '$2a$04$MEOc7PxtnMERV8XDmh6dPO./a3ueB49O07oK.zzM1bJ5oAPHtmRMC', 'Dunc Hovert');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('gterrenk', 'gterrenk@census.gov', '$2a$04$T8j3F5icj26ig6r60NhCU.ipvOo3vguJma4LfR0E1/GGC2pcUBhrW', 'Griselda Terren');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('lzuanl', 'lzuanl@unesco.org', '$2a$04$HR7QbJ2EvmgVyMvjG6UgDOLdqOLK4MKMGLgSD928.EvmIsD/fdVpK', 'Leodora Zuan');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('ymccafferkym', 'ymccafferkym@state.tx.us', '$2a$04$6lIah4KtPlV7Fo3AlTbHk.6QscfTT8YSFmZ7hWFrrT3Lgp6qKi.oS', 'Yolane McCafferky');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('clittn', 'clittn@ed.gov', '$2a$04$KfOL31HejepdqbBhG3gXs.ttow8D6NGFnzpoS1/vGn/.CwlhUgTEq', 'Cory Litt');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('evinsono', 'evinsono@skype.com', '$2a$04$dE2OMevR6g24hZ3FoEDF2usvZPmheMh47kU7uddzpPEKOXy05efYW', 'Eleni Vinson');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('acorgenvinp', 'acorgenvinp@gizmodo.com', '$2a$04$KiPi/n3cg4u5borWHTOWpeSpR4WfnPpqTTD5jUXmWvchQCD4G67AS', 'Annissa Corgenvin');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('hwennamq', 'hwennamq@sitemeter.com', '$2a$04$k9k.3oHhUyXFFAQ8nPrTteNkpsD/ufBrDeUhlcLttNJza3gqm6zoW', 'Hubert Wennam');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('agowryr', 'agowryr@gnu.org', '$2a$04$YZ1Zpyx439sLUMt7ik66huLp.GVtHU.RHPIRUjdOHKDWAZcRv2ZoW', 'Ashly Gowry');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('ysamuelss', 'ysamuelss@infoseek.co.jp', '$2a$04$Hl8u/OGto6Ty/tY0iwOmb.g2TGlQ1OPDP1.9lquv.lLcJ9RWNYNsO', 'Yelena Samuels');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('cuccellit', 'cuccellit@reddit.com', '$2a$04$sgJcnXzCbPfhjgHPEFzxHO4PB2SbdHZRVwcan8m3A0NYe3OwVssPy', 'Carlyle Uccelli');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('gdonohueu', 'gdonohueu@edublogs.org', '$2a$04$v0G9DlcIPP2JKi2qznznSOyzdcWgM1Bwo3G4kqJ4ZVZx1LSrFlQLe', 'Gabie Donohue');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('ccarvillv', 'ccarvillv@telegraph.co.uk', '$2a$04$FwiQGfXXX6U5yqoJ06pj2eXbQ2y5giw5pxOWrWTFlx/FX.YjfbuNK', 'Cassy Carvill');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('begertonw', 'begertonw@51.la', '$2a$04$4LgejCOk1dy4f4Byjvt52ul3orCezwWmpqJRGaHRs1J9tK9PvBUWm', 'Barron Egerton');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('mbaisonx', 'mbaisonx@state.tx.us', '$2a$04$lv0jIsTgvhZEtzEmN3xH.e9pD8bUU4B4KdI5O2LORmyIwKPdrbJ7C', 'Myles Baison');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('khupkay', 'khupkay@disqus.com', '$2a$04$jUCB4DXk.Q3odXN0xbjMeOBeF9pcmiL6dUjQ82rH3.CDS8hZd0LVq', 'Keane Hupka');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('apadellz', 'apadellz@biblegateway.com', '$2a$04$2CNfIB2HqzsAcFUhNDrNdONSKAvEe3JEvdz1Mc8Fw3afvr7aiUL52', 'Aleksandr Padell');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('kwealleans10', 'kwealleans10@squidoo.com', '$2a$04$oMZpV4xd9x2PUDg4dRXBpOXyUjZ1pfv..hECb8PsrBJ3.QSTWZHGu', 'Kristal Wealleans');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('mcowlas11', 'mcowlas11@amazon.com', '$2a$04$xmaTCcuWmhX7TiO7SYNXZufo99jYRKBfS3hloWVcCFdrJ7XjEdcSS', 'Melinda Cowlas');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('atravers12', 'atravers12@cdbaby.com', '$2a$04$4fztUEVyAXp0/CwMauLlieCDN6Gdw8Yz6hLC9YxxIE1S5evM63hHq', 'Alberik Travers');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('tmurrell13', 'tmurrell13@ucoz.com', '$2a$04$w4E/VtGQ1bE2ZLBZchLNquTP.XfWy0Ib2mxMj4adM/LW8HXUDQ3HS', 'Tracie Murrell');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('fglassup14', 'fglassup14@sphinn.com', '$2a$04$/pCPfIBiXGEzHQoN1kDKDeK78p.tv2vyQc1StSxhwCbvwQU1dgOvi', 'Foss Glassup');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('tchapellow15', 'tchapellow15@bbb.org', '$2a$04$I0zi5p8A9gCKTH9wCdbiWuDFn6UgUlgdIZ8lvpRx5UNrgGWt/Uhv.', 'Teddy Chapellow');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('oestick16', 'oestick16@clickbank.net', '$2a$04$Zf4.SX8h.2KoLoE1po/dpugP/qTazA.cdCN5ea98e2qWSGqOY1XZG', 'Oona Estick');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('yockenden17', 'yockenden17@msu.edu', '$2a$04$E9lxyBi.infNbM61bhqy9uwhBhoD2RKj8trF5xQ31MuTPZtlkHN42', 'Yolane Ockenden');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('fscanes18', 'fscanes18@sfgate.com', '$2a$04$W6sOuJbwO6ps31f8egCEzuFo.JVwdrqfS8fkUiy.yexp3OI3tnXMO', 'Florencia Scanes');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('nborrill19', 'nborrill19@issuu.com', '$2a$04$H.aEwZiZUfQmk2FPJu5QbuzrRaVM96KQ6FQ/DfdoPNchX5yz7fFA2', 'Nester Borrill');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('phughson1a', 'phughson1a@twitter.com', '$2a$04$G7pOp3ZCOCxHQ13sE26lo.Gg/jU0QBFPhOYenduDu30i21mJu.Gn2', 'Perry Hughson');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('mdabernott1b', 'mdabernott1b@mediafire.com', '$2a$04$lqe0LjPkNYQMKPcMLCQpseWSbVYrYRsGKLnUQvj/pklnbsuDIsMs6', 'Mel Dabernott');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('ljevons1c', 'ljevons1c@fc2.com', '$2a$04$Va.1ZkgSnZ94YQ0QdY8VX.l2yPA37UDBc5LYBu/iN1M3G01VovIJK', 'Lyndsie Jevons');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('jmaidlow1d', 'jmaidlow1d@ebay.com', '$2a$04$gqMjS2ZgtJLkLTKv7qRNoOQ8fQlp/9oTBlB5mF37s7Xr0zzR0GmYG', 'Joice Maidlow');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('moshiels1e', 'moshiels1e@samsung.com', '$2a$04$ZowGl8Pd19KMYcpQbrlaD.JKJLx4N5p3lMVF.RU7qPVdOLsEmWBr.', 'Maisie O''Shiels');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('dstolz1f', 'dstolz1f@about.com', '$2a$04$6jSrVJNWyg39o.231bNNiOLLfezIEFbybAV4Hdywa2mHkI/BP4Sle', 'Desiri Stolz');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('cjanse1g', 'cjanse1g@yellowbook.com', '$2a$04$O1TqolVxQXaSMWiAUzbDtulyhs5jGQQGgJLOTsYoaX6jAb0PYmFiK', 'Cordelie Janse');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('ageekie1h', 'ageekie1h@facebook.com', '$2a$04$w2sn7UsX0tkz69rNLJmgEugDWb9ICfUl98Dm3fz/qheS/wJCAg4ne', 'Anatola Geekie');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('dyanin1i', 'dyanin1i@gravatar.com', '$2a$04$HgOMgmwNxvCyWdEaLWaNoOnmhk3yO8iJo3up7R5AFI84n3GSGiI8G', 'Darrin Yanin');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('fhonatsch1j', 'fhonatsch1j@dailymotion.com', '$2a$04$zcv2tuLjqLTLUCVVFjtrwuv6xtFnyFHQ57rNimNQx0CZk5mIiYgmC', 'Fredric Honatsch');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('nkilgallon1k', 'nkilgallon1k@hp.com', '$2a$04$Y5H837auauuVWk6FM4yHLOKLAPXhxsjUBYKHB94uFBCjUuATmO3iK', 'Nydia Kilgallon');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('zsends1l', 'zsends1l@umich.edu', '$2a$04$EzztjgSOqdF4efBpoJNgguxHQXu9eKHz8eaT7hztdlDrwgecNxH36', 'Zorine Sends');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('zclaricoats1m', 'zclaricoats1m@youku.com', '$2a$04$3NK6IeoyWNLk.YcjXkFxkuNA/3mbQT1YdeQqZUVHQlyFOdg9.JqXm', 'Zak Claricoats');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('dmc1n', 'dmc1n@a8.net', '$2a$04$VMlIBtpp7bRYzigFCgz60.2H1WDP4rhVIrNjuinXci/159xs08m5C', 'Dagny Mc Kellen');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('shynde1o', 'shynde1o@alibaba.com', '$2a$04$CBzRF0O84IJ8.LDOwLVrDO1W8GBBQ523xvQWFBBNE.FelG04MOT4u', 'Sissy Hynde');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('vtiery1p', 'vtiery1p@ask.com', '$2a$04$5BHHUvVBCSWeRpqGnIodJu4cEOa9I.NUR8IABIBrzXVLdVTMZiq56', 'Veronique Tiery');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('edarben1q', 'edarben1q@disqus.com', '$2a$04$iiuhTK.JIVULh7R68lQfXeKaSu7tRxI4SvesNIvFDZEVi4yDwquvi', 'Elicia Darben');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('hconnop1r', 'hconnop1r@mozilla.org', '$2a$04$/M1DjR7fwtXAPZX5EzJ0d.8YU0SvRBdhuI0jui9odV4eT5DLpMHQS', 'Helaine Connop');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('pmeeson1s', 'pmeeson1s@seesaa.net', '$2a$04$ZxotSn4qr7X/HS51JtAl3OQxXx9iJp7xMUdmg38vx68yllAQIWd86', 'Pru Meeson');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('aelphinstone1t', 'aelphinstone1t@ucoz.com', '$2a$04$kUI7.weHfY8V/CStzLSK9.ALaGyS6.hSorNq61itSduyvd72zzNEa', 'Adorne Elphinstone');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('chansed1u', 'chansed1u@4shared.com', '$2a$04$FbiLYISaVMRxOsQ2982Y8uUc4bPjIW.U9sP6..FgO3fcNmtnwYV6O', 'Corena Hansed');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('emorratt1v', 'emorratt1v@unicef.org', '$2a$04$CyNT7EIxaVFvsNCa8l4Gj.MSEHYi/8KRDfKO4cGt1lE2sA.hxtYQG', 'Elaine Morratt');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('jhulse1w', 'jhulse1w@cbslocal.com', '$2a$04$b0ED2Du3pCHq/US8utRkXuYFGh3Jn5mCKQeKKgIl7z4EdB2Lq6G3O', 'Jemimah Hulse');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('fbrotherhead1x', 'fbrotherhead1x@hp.com', '$2a$04$GZ.MGN7CI9WlB2rz7OBl7OfZ4Wjh5l3iqYYU0mC7tnvTyiRCMUDm6', 'Finley Brotherhead');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('rbroodes1y', 'rbroodes1y@godaddy.com', '$2a$04$SEipHHWYQj3V7MTWPC4JmebhLRjb2Gn5M58Q1xCEA9EajGiEEmMo.', 'Roderigo Broodes');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('iitscowicz1z', 'iitscowicz1z@whitehouse.gov', '$2a$04$3Y5oAt71EMTeZWVVPGmj6efCnvvuIGpR0RagrtKQPL4JT9Tcb..b.', 'Isac Itscowicz');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('wtyght20', 'wtyght20@abc.net.au', '$2a$04$nS88NYkrJ/Qm9CtIQgTPfu8JGQmZoO5QfNoysz5nyDWyTYOryl8B.', 'Washington Tyght');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('ypickburn21', 'ypickburn21@amazon.co.uk', '$2a$04$4JYe1Yb5OfyFPHDA1c4EY.UHmiz/s9rSKdNSVyEPvlk/7uyLj7uTG', 'Yorgos Pickburn');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('cbutters22', 'cbutters22@spiegel.de', '$2a$04$0VYJR539BwalRN0g65ptiethf6t.BVsh93FLeWMEpnTkWVXKba81C', 'Claudelle Butters');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('rharlowe23', 'rharlowe23@ucla.edu', '$2a$04$5tSZVzAMRettvAxl0yen2esKvceI2y4.9Fa9KZwnP0LCcbHHUY3/i', 'Rosalia Harlowe');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('slutwyche24', 'slutwyche24@1688.com', '$2a$04$h709dG9Uozi2MxqHmGhbSOR1oGyDvAVpN0uyo8NrqbxgTeE2UvHnG', 'Sher Lutwyche');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('dinkin25', 'dinkin25@privacy.gov.au', '$2a$04$mtASILgqI2.Pwt.hTJh.a.0iJuMO/ksxJMmQicMd3f.J3zs0vSDva', 'Diann Inkin');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('mwethered26', 'mwethered26@networkadvertising.org', '$2a$04$nKu827lJoG2fEpMWQu3rLOi/nteFu0KFysFEF5Vd8Vz3MHZwdFshu', 'Malchy Wethered');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('alaker27', 'alaker27@mediafire.com', '$2a$04$Eq0vrq8XYJn95JhcmwSCXeFKGw4b7kFllUkiqZecujggo0LM9dzue', 'Annabell Laker');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('cvon28', 'cvon28@deliciousdays.com', '$2a$04$2yPIwuUbK2Y6cMwhgOi/vetS2M5IffZ31gaKw1RPYpTmIFrzyw1Vy', 'Crin Von Hindenburg');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('bgrimstead29', 'bgrimstead29@github.io', '$2a$04$oaeHGE/flN4Ch5UP10/rsuXzcNFl5K9IagFFtC6pz2gV35jIyD3GC', 'Brittani Grimstead');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('csmitton2a', 'csmitton2a@paginegialle.it', '$2a$04$Vd51WLEhpS8OF09XLzxwFeoPlZAJmUhay2raBC17byqLVIDQwnUly', 'Clarey Smitton');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('norknay2b', 'norknay2b@twitpic.com', '$2a$04$X5mjVCrz3mhYWUMpf.3l8OjGKB.a218BDK24P7Vc8Xmb/J6GJMgKW', 'Nicol Orknay');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('lbehnen2c', 'lbehnen2c@google.co.jp', '$2a$04$ltagKeouoZp9JjmtFuq1U.KkNFZZLzJy4rNx7LGGAPBpTYkrl1llO', 'Ludovika Behnen');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('meveriss2d', 'meveriss2d@a8.net', '$2a$04$fJ28oE2p16ScRyU9CYc5juxru.m9pciCFtVuWt6fxPBa8HVlwr6Fq', 'Marillin Everiss');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('dwitt2e', 'dwitt2e@pagesperso-orange.fr', '$2a$04$Cfnkibs69SwKuUZvrOweqONKVJgDsGVsXfWCDKfzFtE1RpDsbglX.', 'De witt Buesden');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('jberni2f', 'jberni2f@freewebs.com', '$2a$04$qpUJB0vy4eZkb9UB47DrR.4tiCD8wgGT6tOYXgFn5mPW9hvGe4Yg2', 'Joela Berni');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('bnolder2g', 'bnolder2g@businesswire.com', '$2a$04$cJ437ryMn46GTTFRVbYn9eMPC8lB7lC4QduA1q5SRJh4bSXySJk.6', 'Bradley Nolder');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('zstaite2h', 'zstaite2h@51.la', '$2a$04$aPz5Q5zC2a6Pkjb8eCn6wOh//ww9II1rUT3/Nnjx7XuOGa.a5mtnC', 'Zoe Staite');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('dkubin2i', 'dkubin2i@pinterest.com', '$2a$04$jutiufsZPzqrHkwGnvv3IuHb1MMCD/kwX9KQayB5mGDstFGjrY6lG', 'Dody Kubin');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('mlamprey2j', 'mlamprey2j@sbwire.com', '$2a$04$soORHHYUvvoKOWPFfOfKLO/mptndvBB9Ds4zZfzusTRoyDpyVMvyu', 'Maximo Lamprey');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('bcullingford2k', 'bcullingford2k@photobucket.com', '$2a$04$IW9yGAVsEWLws1TD0FlbAuio6WwjOfvz9U6mAoVbvqnXF4gCmDcSm', 'Bertha Cullingford');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('kmaletratt2l', 'kmaletratt2l@phoca.cz', '$2a$04$azC8hgancYc/hoYO4Gy6u.yrWfgygVTdQqgPcqNcYuMNGOWHOpyW.', 'Kathryne Maletratt');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('bmclarnon2m', 'bmclarnon2m@answers.com', '$2a$04$bI2NEzeAQsqSw8ETA5oqa.5oT9ClGENMQXHMKF6WJvTe8Obm29qm2', 'Benjy McLarnon');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('cdutteridge2n', 'cdutteridge2n@ftc.gov', '$2a$04$DpFccx9nSJXhi9U1Auea/eNTGiFmBTW1p5sUoyrMis4AaJlWKH0bW', 'Costa Dutteridge');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('jgullan2o', 'jgullan2o@plala.or.jp', '$2a$04$/pemPLkJeo8nOLxxOW4CUu35eEXLIjTDNq84hSGK2OeGYTk6xO1ge', 'Jamal Gullan');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('ewoodson2p', 'ewoodson2p@vimeo.com', '$2a$04$cf62tg37QHiwC4WXs0giO.hRPKRJ8RhrN67Msv4UGAUKGpIc/lvHG', 'Emmeline Woodson');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('ecreamen2q', 'ecreamen2q@liveinternet.ru', '$2a$04$g8U/OJ3kyz8pCrjyM7F8hOHuOLEaDFoym/VO./ZEri8eqBwpAEUdK', 'Edmund Creamen');
INSERT INTO users (username, email, password_hash, display_name) VALUES ('vjosh2r', 'vjosh2r@marketwatch.com', '$2a$04$Q0ErHyrC43e.nC25lnENE.8dUXYQXAv7mIvPqGptMUyfgzWgK/T72', 'Valry Josh');

INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Aufderhar Inc', 14, 'aufderhar-inc', 'We offer over 351 carefully selected items and refresh our collections regularly. Aufderhar Inc is a handmade kids'' toys store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Hegmann, Brekke and Doyle', 93, 'hegmann-brekke-and-doyle', 'Hegmann, Brekke and Doyle is a affordable fashion store, founded in 2004. We offer over 332 carefully selected items and refresh our collections regularly. We pride ourselves on locally sourced products and gift wrapping services.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Mueller-Shields', 72, 'mueller-shields', 'We focus on custom engraving and exclusive member discounts. Mueller-Shields is a eco-friendly kids'' toys store. We offer over 248 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Jacobson, Franecki and Toy', 64, 'jacobson-franecki-and-toy', 'Customers love us for free returns and gift wrapping services. Customers rate our service 4 out of 5 for speed and reliability. Jacobson, Franecki and Toy is a innovative home & living store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Mann, Watsica and Schiller', 41, 'mann-watsica-and-schiller', 'We focus on custom engraving and 24/7 customer support. Mann, Watsica and Schiller is a eco-friendly fashion store. Customers rate our service 4.8 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Runolfsdottir, Hickle and Fadel', 56, 'runolfsdottir-hickle-and-fadel', 'Customers love us for personalized recommendations and fast, tracked shipping. We offer over 560 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Bosco, Gusikowski and Botsford', 1, 'bosco-gusikowski-and-botsford', 'Bosco, Gusikowski and Botsford is a curated outdoor gear store. We offer over 623 carefully selected items and refresh our collections regularly. Sign up for exclusive offers and early access.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Harvey LLC', 62, 'harvey-llc', 'Sign up for exclusive offers and early access. Customers love us for custom engraving and fast, tracked shipping. Customers rate our service 4.9 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Turcotte Group', 38, 'turcotte-group', 'Customers rate our service 4.1 out of 5 for speed and reliability. Sign up for exclusive offers and early access.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Nader-Schulist', 34, 'nader-schulist', 'Nader-Schulist is a innovative pet supplies store. We pride ourselves on a 2-year warranty and detailed product guides. Shop our latest collection today. Customers rate our service 4.8 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Schinner-Lemke', 65, 'schinner-lemke', 'Schinner-Lemke is a handmade electronics store. Free returns within 30 days.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Rohan Group', 9, 'rohan-group', 'Rohan Group is a innovative beauty & wellness store. Shop our latest collection today. We offer over 473 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Lemke, Kessler and Jones', 40, 'lemke-kessler-and-jones', 'Shop our latest collection today. Customers rate our service 4.6 out of 5 for speed and reliability. Lemke, Kessler and Jones is a premium outdoor gear store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Kassulke, Smitham and Greenfelder', 45, 'kassulke-smitham-and-greenfelder', 'Free returns within 30 days. We offer over 257 carefully selected items and refresh our collections regularly. Kassulke, Smitham and Greenfelder is a fast-growing artisanal food store. We focus on custom engraving and detailed product guides.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Reichert Group', 59, 'reichert-group', 'Sign up for exclusive offers and early access. Customers love us for eco-friendly packaging and exclusive member discounts. We offer over 131 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Jast, VonRueden and Barrows', 47, 'jast-vonrueden-and-barrows', 'Jast, VonRueden and Barrows is a innovative outdoor gear store. Customers rate our service 4.3 out of 5 for speed and reliability. We focus on free returns and detailed product guides.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Stanton, Keebler and Smith', 20, 'stanton-keebler-and-smith', 'Customers love us for same-day dispatch and exclusive member discounts. Free returns within 30 days.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Stracke-Marvin', 35, 'stracke-marvin', 'Customers rate our service 4 out of 5 for speed and reliability. Sign up for exclusive offers and early access. Stracke-Marvin is a family-run pet supplies store, founded in 2014.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Williamson, Bashirian and Koepp', 49, 'williamson-bashirian-and-koepp', 'Discover our best sellers now. Our team guarantees free returns and exclusive member discounts.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Rippin-Anderson', 27, 'rippin-anderson', 'Rippin-Anderson is a luxury kids'' toys store. Customers love us for eco-friendly packaging and exclusive member discounts.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Rodriguez, Yost and O''Reilly', 72, 'rodriguez-yost-and-oreilly', 'Free returns within 30 days. Rodriguez, Yost and O''Reilly is a eco-friendly artisanal food store, founded in 2014. Customers rate our service 4.6 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Swaniawski, Koelpin and Schiller', 82, 'swaniawski-koelpin-and-schiller', 'Customers rate our service 4.2 out of 5 for speed and reliability. Sign up for exclusive offers and early access.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Morissette, Weissnat and Murazik', 26, 'morissette-weissnat-and-murazik', 'Discover our best sellers now. We pride ourselves on price match guarantee and exclusive member discounts. Morissette, Weissnat and Murazik is a premium home & living store. Customers rate our service 4.9 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Koelpin-Klocko', 76, 'koelpin-klocko', 'Sign up for exclusive offers and early access. We focus on personalized recommendations and exclusive member discounts. Koelpin-Klocko is a curated sports equipment store. Customers rate our service 4.1 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Emard-Langosh', 11, 'emard-langosh', 'Discover our best sellers now. We pride ourselves on eco-friendly packaging and detailed product guides. Customers rate our service 4.8 out of 5 for speed and reliability. Emard-Langosh is a handmade kids'' toys store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Nader, Dickens and King', 36, 'nader-dickens-and-king', 'We focus on locally sourced products and detailed product guides. Discover our best sellers now.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Block, Dare and Gottlieb', 51, 'block-dare-and-gottlieb', 'Discover our best sellers now. We pride ourselves on eco-friendly packaging and exclusive member discounts.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Schamberger, Schmeler and Cummerata', 82, 'schamberger-schmeler-and-cummerata', 'Schamberger, Schmeler and Cummerata is a handmade sports equipment store. Customers love us for locally sourced products and secure checkout. Shop our latest collection today.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Hyatt, Abshire and Herzog', 100, 'hyatt-abshire-and-herzog', 'We focus on eco-friendly packaging and detailed product guides. We offer over 764 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Ferry, Ritchie and Lang', 55, 'ferry-ritchie-and-lang', 'We focus on a 2-year warranty and fast, tracked shipping. We offer over 989 carefully selected items and refresh our collections regularly. Ferry, Ritchie and Lang is a family-run electronics store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Daniel-Deckow', 40, 'daniel-deckow', 'Discover our best sellers now. Customers rate our service 4.6 out of 5 for speed and reliability. We focus on price match guarantee and exclusive member discounts. Daniel-Deckow is a handmade electronics store, founded in 2003.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Rolfson, Lind and Strosin', 42, 'rolfson-lind-and-strosin', 'We offer over 474 carefully selected items and refresh our collections regularly. We pride ourselves on locally sourced products and exclusive member discounts.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Jaskolski LLC', 86, 'jaskolski-llc', 'Customers love us for a 2-year warranty and fast, tracked shipping. We offer over 123 carefully selected items and refresh our collections regularly. Jaskolski LLC is a eco-friendly beauty & wellness store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Gleason, Upton and King', 15, 'gleason-upton-and-king', 'Our team guarantees eco-friendly packaging and secure checkout. Customers rate our service 4.5 out of 5 for speed and reliability. Gleason, Upton and King is a fast-growing handmade goods store. Discover our best sellers now.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Gulgowski Inc', 62, 'gulgowski-inc', 'We pride ourselves on personalized recommendations and detailed product guides. Customers rate our service 4.4 out of 5 for speed and reliability. Gulgowski Inc is a boutique handmade goods store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Weber Inc', 60, 'weber-inc', 'Weber Inc is a handmade pet supplies store, founded in 2001. We offer over 598 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Schuppe-Gutmann', 33, 'schuppe-gutmann', 'Schuppe-Gutmann is a innovative outdoor gear store. Discover our best sellers now. Our team guarantees locally sourced products and exclusive member discounts. We offer over 992 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Daugherty-Parisian', 57, 'daugherty-parisian', 'Sign up for exclusive offers and early access. Daugherty-Parisian is a eco-friendly outdoor gear store. We focus on price match guarantee and detailed product guides.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Heller-Schumm', 100, 'heller-schumm', 'We offer over 778 carefully selected items and refresh our collections regularly. Our team guarantees eco-friendly packaging and 24/7 customer support.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Bernier-Fisher', 36, 'bernier-fisher', 'We offer over 522 carefully selected items and refresh our collections regularly. Sign up for exclusive offers and early access. Customers love us for free returns and 24/7 customer support.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Kris, Morar and Kuvalis', 43, 'kris-morar-and-kuvalis', 'We offer over 242 carefully selected items and refresh our collections regularly. Kris, Morar and Kuvalis is a luxury electronics store. We focus on free returns and secure checkout. Free returns within 30 days.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Smitham and Sons', 66, 'smitham-and-sons', 'Smitham and Sons is a premium pet supplies store. Customers rate our service 4.1 out of 5 for speed and reliability. Customers love us for free returns and exclusive member discounts.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Bode, Morissette and Gislason', 16, 'bode-morissette-and-gislason', 'Shop our latest collection today. Customers rate our service 4 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Johns, McCullough and Wiza', 19, 'johns-mccullough-and-wiza', 'Johns, McCullough and Wiza is a eco-friendly artisanal food store. We focus on same-day dispatch and secure checkout.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Denesik, Runte and Gislason', 89, 'denesik-runte-and-gislason', 'Denesik, Runte and Gislason is a fast-growing sports equipment store. Sign up for exclusive offers and early access.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Heaney-Harber', 12, 'heaney-harber', 'We offer over 561 carefully selected items and refresh our collections regularly. We focus on eco-friendly packaging and fast, tracked shipping. Heaney-Harber is a family-run home & living store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Dickens-Leannon', 58, 'dickens-leannon', 'Customers rate our service 4 out of 5 for speed and reliability. We focus on free returns and detailed product guides.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('DuBuque-Schneider', 70, 'dubuque-schneider', 'DuBuque-Schneider is a eco-friendly electronics store. Customers love us for personalized recommendations and 24/7 customer support. Customers rate our service 4.6 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Casper, Powlowski and Goyette', 70, 'casper-powlowski-and-goyette', 'We offer over 485 carefully selected items and refresh our collections regularly. We focus on a 2-year warranty and 24/7 customer support. Free returns within 30 days. Casper, Powlowski and Goyette is a curated home & living store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Schmidt, Abernathy and Daniel', 17, 'schmidt-abernathy-and-daniel', 'Free returns within 30 days. Schmidt, Abernathy and Daniel is a premium fashion store, founded in 2001. Customers rate our service 4.5 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Pfeffer-Orn', 27, 'pfeffer-orn', 'Customers rate our service 4.3 out of 5 for speed and reliability. Sign up for exclusive offers and early access. Pfeffer-Orn is a family-run electronics store, founded in 2012.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Bayer-Padberg', 82, 'bayer-padberg', 'Customers love us for personalized recommendations and gift wrapping services. We offer over 933 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Connelly-Bernier', 19, 'connelly-bernier', 'We focus on personalized recommendations and fast, tracked shipping. We offer over 377 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Conn, Denesik and Conroy', 54, 'conn-denesik-and-conroy', 'Conn, Denesik and Conroy is a affordable electronics store. Customers rate our service 4.3 out of 5 for speed and reliability. Sign up for exclusive offers and early access.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Bartell-Frami', 28, 'bartell-frami', 'We offer over 914 carefully selected items and refresh our collections regularly. Bartell-Frami is a premium artisanal food store. Discover our best sellers now. We pride ourselves on same-day dispatch and secure checkout.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Stokes-Koss', 7, 'stokes-koss', 'Customers rate our service 4.1 out of 5 for speed and reliability. Sign up for exclusive offers and early access.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Morar-Weissnat', 71, 'morar-weissnat', 'Our team guarantees same-day dispatch and fast, tracked shipping. Shop our latest collection today. Morar-Weissnat is a eco-friendly beauty & wellness store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Reichert, Reilly and Pagac', 62, 'reichert-reilly-and-pagac', 'Reichert, Reilly and Pagac is a family-run kids'' toys store. Customers rate our service 4.6 out of 5 for speed and reliability. We pride ourselves on personalized recommendations and detailed product guides.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Dickinson and Sons', 85, 'dickinson-and-sons', 'Dickinson and Sons is a luxury home & living store. We pride ourselves on custom engraving and secure checkout.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Schneider Group', 35, 'schneider-group', 'We offer over 598 carefully selected items and refresh our collections regularly. We pride ourselves on free returns and exclusive member discounts. Schneider Group is a premium home & living store, founded in 2009.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Williamson Inc', 100, 'williamson-inc', 'Customers rate our service 5 out of 5 for speed and reliability. Williamson Inc is a affordable handmade goods store. Our team guarantees price match guarantee and 24/7 customer support.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Rau Inc', 98, 'rau-inc', 'Customers rate our service 5 out of 5 for speed and reliability. Rau Inc is a fast-growing kids'' toys store. We focus on personalized recommendations and 24/7 customer support. Discover our best sellers now.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Gerlach, Bergnaum and Kovacek', 86, 'gerlach-bergnaum-and-kovacek', 'Our team guarantees free returns and 24/7 customer support. Free returns within 30 days.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Hills, Little and Schulist', 89, 'hills-little-and-schulist', 'We focus on free returns and exclusive member discounts. We offer over 439 carefully selected items and refresh our collections regularly. Hills, Little and Schulist is a innovative artisanal food store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Collier-Auer', 70, 'collier-auer', 'Free returns within 30 days. Customers rate our service 4.4 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Blanda Inc', 79, 'blanda-inc', 'Free returns within 30 days. Blanda Inc is a affordable sports equipment store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Christiansen LLC', 79, 'christiansen-llc', 'We focus on eco-friendly packaging and exclusive member discounts. We offer over 634 carefully selected items and refresh our collections regularly. Sign up for exclusive offers and early access. Christiansen LLC is a fast-growing electronics store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Bins Group', 19, 'bins-group', 'Customers rate our service 4 out of 5 for speed and reliability. Discover our best sellers now. Our team guarantees a 2-year warranty and secure checkout. Bins Group is a family-run kids'' toys store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Hettinger-Cormier', 50, 'hettinger-cormier', 'Sign up for exclusive offers and early access. Customers rate our service 4.5 out of 5 for speed and reliability. Hettinger-Cormier is a innovative kids'' toys store, founded in 2012.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Wyman-Franecki', 75, 'wyman-franecki', 'Wyman-Franecki is a fast-growing handmade goods store. Customers rate our service 4 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Feil LLC', 20, 'feil-llc', 'Customers rate our service 4.8 out of 5 for speed and reliability. Shop our latest collection today. Feil LLC is a handmade outdoor gear store. Our team guarantees personalized recommendations and exclusive member discounts.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Pacocha and Sons', 73, 'pacocha-and-sons', 'We pride ourselves on price match guarantee and gift wrapping services. Pacocha and Sons is a family-run fashion store. We offer over 108 carefully selected items and refresh our collections regularly. Free returns within 30 days.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Rau-Pfannerstill', 36, 'rau-pfannerstill', 'Rau-Pfannerstill is a curated handmade goods store. We focus on price match guarantee and gift wrapping services. Shop our latest collection today.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Kovacek and Sons', 4, 'kovacek-and-sons', 'Shop our latest collection today. Customers love us for a 2-year warranty and secure checkout.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Hoeger, Rodriguez and Bayer', 51, 'hoeger-rodriguez-and-bayer', 'Discover our best sellers now. We pride ourselves on personalized recommendations and detailed product guides.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Reynolds, Jast and Abernathy', 67, 'reynolds-jast-and-abernathy', 'Reynolds, Jast and Abernathy is a fast-growing handmade goods store. Discover our best sellers now.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Kunde and Sons', 84, 'kunde-and-sons', 'Our team guarantees price match guarantee and secure checkout. Sign up for exclusive offers and early access. We offer over 920 carefully selected items and refresh our collections regularly. Kunde and Sons is a boutique home & living store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Oberbrunner LLC', 64, 'oberbrunner-llc', 'We focus on a 2-year warranty and 24/7 customer support. Sign up for exclusive offers and early access. Oberbrunner LLC is a innovative kids'' toys store, founded in 2023. We offer over 282 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Schroeder LLC', 6, 'schroeder-llc', 'Discover our best sellers now. We focus on custom engraving and exclusive member discounts. Schroeder LLC is a fast-growing beauty & wellness store, founded in 2001. We offer over 815 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Marvin-Rohan', 8, 'marvin-rohan', 'We offer over 679 carefully selected items and refresh our collections regularly. We pride ourselves on free returns and 24/7 customer support. Marvin-Rohan is a luxury beauty & wellness store. Shop our latest collection today.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Okuneva-Wolff', 47, 'okuneva-wolff', 'Free returns within 30 days. Okuneva-Wolff is a handmade pet supplies store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Nader, Feil and Price', 19, 'nader-feil-and-price', 'Customers rate our service 4.9 out of 5 for speed and reliability. Shop our latest collection today. Nader, Feil and Price is a affordable pet supplies store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Christiansen-Haag', 37, 'christiansen-haag', 'Christiansen-Haag is a curated handmade goods store. Customers love us for free returns and fast, tracked shipping. Sign up for exclusive offers and early access.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Turner-Lockman', 44, 'turner-lockman', 'Turner-Lockman is a boutique home & living store, founded in 2018. Customers love us for personalized recommendations and detailed product guides. Customers rate our service 4.3 out of 5 for speed and reliability. Free returns within 30 days.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Smitham LLC', 97, 'smitham-llc', 'We focus on eco-friendly packaging and detailed product guides. Discover our best sellers now.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Windler Group', 3, 'windler-group', 'We offer over 752 carefully selected items and refresh our collections regularly. Our team guarantees same-day dispatch and exclusive member discounts.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Crona, Medhurst and Bashirian', 53, 'crona-medhurst-and-bashirian', 'Sign up for exclusive offers and early access. Our team guarantees eco-friendly packaging and detailed product guides.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Lang, Roob and Greenholt', 7, 'lang-roob-and-greenholt', 'Discover our best sellers now. Lang, Roob and Greenholt is a innovative outdoor gear store. We focus on free returns and fast, tracked shipping.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Muller, Corwin and Grimes', 31, 'muller-corwin-and-grimes', 'Muller, Corwin and Grimes is a curated artisanal food store, founded in 2013. Free returns within 30 days. We offer over 496 carefully selected items and refresh our collections regularly. Customers love us for personalized recommendations and gift wrapping services.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Baumbach LLC', 8, 'baumbach-llc', 'Free returns within 30 days. Baumbach LLC is a innovative outdoor gear store. Customers rate our service 4.5 out of 5 for speed and reliability. Our team guarantees free returns and fast, tracked shipping.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Conroy Group', 69, 'conroy-group', 'Free returns within 30 days. Customers rate our service 4.2 out of 5 for speed and reliability. Conroy Group is a luxury sports equipment store, founded in 2002. We pride ourselves on custom engraving and detailed product guides.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Schowalter, Lindgren and Tremblay', 81, 'schowalter-lindgren-and-tremblay', 'Customers love us for personalized recommendations and exclusive member discounts. Shop our latest collection today. Schowalter, Lindgren and Tremblay is a eco-friendly home & living store. We offer over 865 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Lehner and Sons', 94, 'lehner-and-sons', 'We offer over 441 carefully selected items and refresh our collections regularly. Lehner and Sons is a handmade home & living store. Sign up for exclusive offers and early access. Customers love us for same-day dispatch and gift wrapping services.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Langworth, Ratke and Maggio', 62, 'langworth-ratke-and-maggio', 'Free returns within 30 days. Customers love us for free returns and exclusive member discounts. Langworth, Ratke and Maggio is a affordable beauty & wellness store, founded in 2017. We offer over 77 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Kshlerin, Conn and Fisher', 38, 'kshlerin-conn-and-fisher', 'Kshlerin, Conn and Fisher is a eco-friendly fashion store, founded in 2002. Our team guarantees free returns and fast, tracked shipping.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Nienow and Sons', 27, 'nienow-and-sons', 'Customers love us for personalized recommendations and 24/7 customer support. We offer over 286 carefully selected items and refresh our collections regularly. Free returns within 30 days.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Pouros-Casper', 86, 'pouros-casper', 'Our team guarantees a 2-year warranty and secure checkout. Pouros-Casper is a luxury pet supplies store. Free returns within 30 days. We offer over 562 carefully selected items and refresh our collections regularly.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Prohaska Inc', 74, 'prohaska-inc', 'Free returns within 30 days. Customers rate our service 4.9 out of 5 for speed and reliability.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Bailey, Larkin and Lehner', 7, 'bailey-larkin-and-lehner', 'We pride ourselves on personalized recommendations and fast, tracked shipping. Bailey, Larkin and Lehner is a fast-growing fashion store.');
INSERT INTO stores (name, owner_user_id, slug, description) VALUES ('Gutkowski-Stroman', 27, 'gutkowski-stroman', 'Customers rate our service 4.8 out of 5 for speed and reliability. Gutkowski-Stroman is a innovative fashion store. We pride ourselves on price match guarantee and gift wrapping services. Free returns within 30 days.');
