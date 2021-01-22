-- Table: public.Interface

-- DROP TABLE public."Interface";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: public.interface

-- DROP TABLE public.interface;

CREATE TABLE public.interface
(
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    u_name text COLLATE pg_catalog."default" NOT NULL,
    port integer,
    ip inet,
    public_key character(45) COLLATE pg_catalog."default",
    fqdn character varying(253) COLLATE pg_catalog."default",
    CONSTRAINT "Account_pkey" PRIMARY KEY (id),
    CONSTRAINT name_unique UNIQUE (u_name)
        INCLUDE(u_name),
    CONSTRAINT public_key_unique UNIQUE (u_name)
        INCLUDE(u_name)
)

TABLESPACE pg_default;

ALTER TABLE public.interface
    OWNER to postgres;

-- Table: public.interface_password

-- DROP TABLE public.interface_password;

CREATE TABLE public.interface_password
(
    id uuid NOT NULL,
    password_hash character varying(128) COLLATE pg_catalog."default" NOT NULL,
    salt character varying(128) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "InterfacePassword_pkey" PRIMARY KEY (id),
    CONSTRAINT id FOREIGN KEY (id)
        REFERENCES public.interface (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.interface_password
    OWNER to postgres;

-- Table: public.peer_relation

-- DROP TABLE public.peer_relation;

CREATE TABLE public.peer_relation
(
    endpoint_id uuid NOT NULL,
    peer_id uuid NOT NULL,
    peer_allowed_ip inet[] NOT NULL DEFAULT '{}'::inet[],
    endpoint_allowed_ip inet[] NOT NULL DEFAULT '{}'::inet[],
    peer_name text COLLATE pg_catalog."default" NOT NULL,
    endpoint_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT peer_relation_tuple PRIMARY KEY (endpoint_id, peer_id)
        INCLUDE(endpoint_id, peer_id),
    CONSTRAINT endpoint_name_unique UNIQUE (endpoint_name)
        INCLUDE(endpoint_name),
    CONSTRAINT peer_name_unique UNIQUE (peer_name)
        INCLUDE(peer_name),
    CONSTRAINT endpoint_id_foreign FOREIGN KEY (endpoint_id)
        REFERENCES public.interface (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT endpoint_name_foreign FOREIGN KEY (endpoint_name)
        REFERENCES public.interface (u_name) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT peer_id_foreign FOREIGN KEY (peer_id)
        REFERENCES public.interface (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT peer_name_foreign FOREIGN KEY (peer_name)
        REFERENCES public.interface (u_name) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.peer_relation
    OWNER to postgres;

-- Table: public.admin

-- DROP TABLE public.admin;

CREATE TABLE public.admin
(
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    u_name text COLLATE pg_catalog."default" NOT NULL,
    is_root boolean NOT NULL,
    CONSTRAINT "User_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public.admin
    OWNER to postgres;

-- Table: public.admin_password

-- DROP TABLE public.admin_password;

CREATE TABLE public.admin_password
(
    id uuid NOT NULL,
    password_hash character varying(128) COLLATE pg_catalog."default" NOT NULL,
    salt character varying(128) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Password_pkey" PRIMARY KEY (id),
    CONSTRAINT id FOREIGN KEY (id)
        REFERENCES public.admin (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public.admin_password
    OWNER to postgres;

Insert INTO public.admin (u_name, is_root)
Values ('root', true);
