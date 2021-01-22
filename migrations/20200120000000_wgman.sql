-- Table: public.Interface

-- DROP TABLE public."Interface";

CREATE TABLE public."Interface"
(
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    name text COLLATE pg_catalog."default" NOT NULL,
    port integer,
    ip inet,
    public_key character(45) COLLATE pg_catalog."default",
    fqdn character varying(253) COLLATE pg_catalog."default",
    CONSTRAINT "Account_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE public."Interface"
    OWNER to postgres;

-- Table: public.InterfacePassword

-- DROP TABLE public."InterfacePassword";

CREATE TABLE public."InterfacePassword"
(
    id uuid NOT NULL,
    password_hash character varying(128) COLLATE pg_catalog."default" NOT NULL,
    salt character varying(128) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "InterfacePassword_pkey" PRIMARY KEY (id),
    CONSTRAINT id FOREIGN KEY (id)
        REFERENCES public."Interface" (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public."InterfacePassword"
    OWNER to postgres;

-- Table: public.User

-- DROP TABLE public."User";

CREATE TABLE public."User"
(
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    name text COLLATE pg_catalog."default" NOT NULL,
    is_admin boolean NOT NULL,
    CONSTRAINT "User_pkey" PRIMARY KEY (id)
)

Insert INTO public."User" (name, is_admin)
Values ('admin', true);

TABLESPACE pg_default;

ALTER TABLE public."User"
    OWNER to postgres;

-- Table: public.UserPassword

-- DROP TABLE public."UserPassword";

CREATE TABLE public."UserPassword"
(
    id uuid NOT NULL,
    password_hash character varying(128) COLLATE pg_catalog."default" NOT NULL,
    salt character varying(128) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Password_pkey" PRIMARY KEY (id),
    CONSTRAINT id FOREIGN KEY (id)
        REFERENCES public."User" (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public."UserPassword"
    OWNER to postgres;
    
-- Table: public.PeerRelation

-- DROP TABLE public."PeerRelation";

CREATE TABLE public."PeerRelation"
(
    endpoint_id uuid NOT NULL,
    peer_id uuid NOT NULL,
    peer_allowed_ip inet[] NOT NULL DEFAULT '{}'::inet[],
    endpoint_allowed_ip inet[] NOT NULL DEFAULT '{}'::inet[],
    peer_name text COLLATE pg_catalog."default" NOT NULL,
    endpoint_name text COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT peer_relation PRIMARY KEY (endpoint_id, peer_id)
        INCLUDE(endpoint_id, peer_id),
    CONSTRAINT endpoint_name_unique UNIQUE (endpoint_name)
        INCLUDE(endpoint_name),
    CONSTRAINT peer_name_unique UNIQUE (peer_name)
        INCLUDE(peer_name),
    CONSTRAINT endpoint_id_foreign FOREIGN KEY (endpoint_id)
        REFERENCES public."Interface" (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT endpoint_name_foreign FOREIGN KEY (endpoint_name)
        REFERENCES public."Interface" (name) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT peer_id_foreign FOREIGN KEY (peer_id)
        REFERENCES public."Interface" (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT peer_name_foreign FOREIGN KEY (peer_name)
        REFERENCES public."Interface" (name) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE public."PeerRelation"
    OWNER to postgres;
