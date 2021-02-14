-- Table: public.Interface

-- DROP TABLE public."Interface";
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: public.interface

-- DROP TABLE public.interface;

CREATE TABLE public.interface
(
    u_name text COLLATE pg_catalog."default" NOT NULL,
    port integer,
    ip inet,
    public_key character(44) COLLATE pg_catalog."default",
    fqdn character varying(253) COLLATE pg_catalog."default",
    CONSTRAINT "Account_pkey" PRIMARY KEY (public_key),
    CONSTRAINT name_unique UNIQUE (u_name)
        INCLUDE(u_name),
    CONSTRAINT public_key_unique UNIQUE (public_key)
        INCLUDE(public_key)
);

-- Table: public.interface_password

-- DROP TABLE public.interface_password;

CREATE TABLE public.interface_password
(
    u_name text COLLATE pg_catalog."default" NOT NULL,
    password_hash bytea NOT NULL,
    salt bytea NOT NULL,
    CONSTRAINT "InterfacePassword_pkey" PRIMARY KEY (u_name),
    CONSTRAINT interface_pw_name_unique UNIQUE (u_name)
        INCLUDE(u_name),
    CONSTRAINT interface_pw_name_foreign FOREIGN KEY (u_name)
        REFERENCES public.interface (u_name) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
        NOT VALID
);

-- Table: public.peer_relation

-- DROP TABLE public.peer_relation;

CREATE TABLE public.peer_relation
(
    peer_name character(44) COLLATE pg_catalog."default" NOT NULL,
    endpoint_name character(44) COLLATE pg_catalog."default" NOT NULL,
    peer_allowed_ip inet[] DEFAULT '{}'::inet[],
    endpoint_allowed_ip inet[] DEFAULT '{}'::inet[],
    peer_public_key character(44) COLLATE pg_catalog."default",
    endpoint_public_key character(44) COLLATE pg_catalog."default",

    CONSTRAINT peer_relation_tuple PRIMARY KEY (peer_name, endpoint_name)
        INCLUDE(peer_allowed_ip, endpoint_allowed_ip),
    CONSTRAINT endpoint_public_key_unique UNIQUE (endpoint_public_key)
        INCLUDE(endpoint_public_key),
    CONSTRAINT peer_public_key_unique UNIQUE (peer_public_key)
        INCLUDE(peer_public_key),
    CONSTRAINT endpoint_public_key_foreign FOREIGN KEY (endpoint_public_key)
        REFERENCES public.interface (public_key) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
        NOT VALID,
    CONSTRAINT peer_public_key_foreign FOREIGN KEY (peer_public_key)
        REFERENCES public.interface (public_key) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
        NOT VALID,
    CONSTRAINT endpoint_name_unique UNIQUE (endpoint_name)
        INCLUDE(endpoint_name),
    CONSTRAINT peer_name_unique UNIQUE (peer_name)
        INCLUDE(peer_name),
    CONSTRAINT endpoint_name_foreign FOREIGN KEY (endpoint_name)
        REFERENCES public.interface (u_name) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
        NOT VALID,
    CONSTRAINT peer_name_foreign FOREIGN KEY (peer_name)
        REFERENCES public.interface (u_name) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
        NOT VALID
);



-- Table: public.admin

-- DROP TABLE public.admin;

CREATE TABLE public.admin
(
    u_name text COLLATE pg_catalog."default" NOT NULL,
    is_root boolean NOT NULL,
    CONSTRAINT "User_pkey" PRIMARY KEY (u_name),
    CONSTRAINT admin_name_unique UNIQUE (u_name)
        INCLUDE(u_name)
);

-- Table: public.admin_password

-- DROP TABLE public.admin_password;

CREATE TABLE public.admin_password
(
    u_name text COLLATE pg_catalog."default" NOT NULL,
    password_hash bytea NOT NULL,
    salt bytea NOT NULL,
    CONSTRAINT "Password_pkey" PRIMARY KEY (u_name),
    CONSTRAINT admin_pw_name_unique UNIQUE (u_name)
        INCLUDE(u_name),
    CONSTRAINT admin_pw_name_foreign FOREIGN KEY (u_name)
        REFERENCES public.admin (u_name) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
        NOT VALID
);

Insert INTO public.admin (u_name, is_root)
Values ('root', true);
