--
-- PostgreSQL database dump
--

\restrict mifFuKpHTaUhjOAIL7HUon0r6F1Nd7vhIL8vDFnjK9OchlCQOJ4fh1GtkMRMP0T

-- Dumped from database version 18.1 (Debian 18.1-2)
-- Dumped by pg_dump version 18.1 (Debian 18.1-2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: generer_numero_recu(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generer_numero_recu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.numero_recu := 'REC-' ||
                       TO_CHAR(NOW(), 'YYYY') || '-' ||
                       LPAD(nextval('recu_sequence')::TEXT, 6, '0');
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comptes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comptes (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    mot_de_passe character varying(255) NOT NULL,
    role character varying(30) NOT NULL,
    departement_id integer,
    actif boolean DEFAULT true,
    derniere_connexion timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT comptes_role_check CHECK (((role)::text = ANY ((ARRAY['admin_master'::character varying, 'prefecture'::character varying, 'sous_prefecture'::character varying, 'mairie'::character varying])::text[])))
);


--
-- Name: comptes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comptes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comptes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comptes_id_seq OWNED BY public.comptes.id;


--
-- Name: departements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departements (
    id integer NOT NULL,
    nom character varying(150) NOT NULL,
    type character varying(30) NOT NULL,
    code_dept character varying(20) NOT NULL,
    district_id integer,
    region_id integer,
    prefecture_id integer,
    sous_prefecture_id integer,
    actif boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT departements_type_check CHECK (((type)::text = ANY ((ARRAY['ministere'::character varying, 'prefecture'::character varying, 'sous_prefecture'::character varying, 'mairie'::character varying])::text[])))
);


--
-- Name: departements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.departements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: departements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.departements_id_seq OWNED BY public.departements.id;


--
-- Name: districts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.districts (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    code character varying(10) NOT NULL
);


--
-- Name: districts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.districts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: districts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.districts_id_seq OWNED BY public.districts.id;


--
-- Name: historique; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.historique (
    id integer NOT NULL,
    enregistrement_id integer,
    action character varying(50) NOT NULL,
    ancien_statut character varying(20),
    nouveau_statut character varying(20),
    effectue_par character varying(100),
    commentaire text,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: historique_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.historique_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: historique_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.historique_id_seq OWNED BY public.historique.id;


--
-- Name: localisation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.localisation (
    id integer NOT NULL,
    village character varying(100) NOT NULL,
    district character varying(100) NOT NULL,
    region character varying(100) NOT NULL,
    pays character varying(50) DEFAULT 'Côte d''Ivoire'::character varying
);


--
-- Name: localisation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.localisation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: localisation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.localisation_id_seq OWNED BY public.localisation.id;


--
-- Name: localites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.localites (
    id integer NOT NULL,
    nom character varying(150) NOT NULL,
    type character varying(30) NOT NULL,
    sous_prefecture_id integer,
    prefecture_id integer,
    region_id integer,
    latitude numeric(10,7),
    longitude numeric(10,7),
    population_estimee integer,
    actif boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    numero_menu integer,
    CONSTRAINT localites_type_check CHECK (((type)::text = ANY ((ARRAY['village'::character varying, 'campement'::character varying, 'quartier_rural'::character varying, 'ville'::character varying])::text[])))
);


--
-- Name: localites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.localites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: localites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.localites_id_seq OWNED BY public.localites.id;


--
-- Name: officiers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.officiers (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    matricule character varying(50) NOT NULL,
    departement_id integer,
    actif boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: officiers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.officiers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: officiers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.officiers_id_seq OWNED BY public.officiers.id;


--
-- Name: parents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parents (
    id integer NOT NULL,
    nom_pere character varying(100),
    prenom_pere character varying(100),
    telephone_pere character varying(20),
    nom_mere character varying(100),
    prenom_mere character varying(100),
    telephone_mere character varying(20),
    sous_prefecture_id integer,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: parents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parents_id_seq OWNED BY public.parents.id;


--
-- Name: postgresql_driver; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postgresql_driver (
);


--
-- Name: pre_enregistrements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pre_enregistrements (
    id integer NOT NULL,
    numero_recu character varying(50),
    nom_enfant character varying(100) NOT NULL,
    prenom_enfant character varying(100),
    sexe character(1) NOT NULL,
    date_naissance date NOT NULL,
    heure_naissance time without time zone,
    lieu_naissance character varying(150),
    parents_id integer,
    sous_prefecture_id integer,
    departement_id integer,
    code_ussd character varying(20) DEFAULT '*129#'::character varying,
    telephone_declarant character varying(20),
    statut character varying(20) DEFAULT 'en_attente'::character varying,
    officier_id integer,
    date_validation timestamp without time zone,
    motif_rejet text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    localite_id integer,
    CONSTRAINT pre_enregistrements_sexe_check CHECK ((sexe = ANY (ARRAY['M'::bpchar, 'F'::bpchar]))),
    CONSTRAINT pre_enregistrements_statut_check CHECK (((statut)::text = ANY ((ARRAY['en_attente'::character varying, 'valide'::character varying, 'rejete'::character varying])::text[])))
);


--
-- Name: pre_enregistrements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pre_enregistrements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pre_enregistrements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pre_enregistrements_id_seq OWNED BY public.pre_enregistrements.id;


--
-- Name: prefectures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prefectures (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    code character varying(10) NOT NULL,
    region_id integer,
    numero_menu integer
);


--
-- Name: prefectures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.prefectures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: prefectures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.prefectures_id_seq OWNED BY public.prefectures.id;


--
-- Name: recu_sequence; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recu_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.regions (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    code character varying(10) NOT NULL,
    district_id integer,
    numero_menu integer
);


--
-- Name: regions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.regions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.regions_id_seq OWNED BY public.regions.id;


--
-- Name: sessions_ussd; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions_ussd (
    id integer NOT NULL,
    telephone character varying(20) NOT NULL,
    etape character varying(30) DEFAULT 'choix_region'::character varying,
    region_id integer,
    prefecture_id integer,
    sous_prefecture_id integer,
    localite_id integer,
    nom_enfant character varying(100),
    prenom_enfant character varying(100),
    sexe character(1),
    date_naissance date,
    nom_pere character varying(100),
    prenom_pere character varying(100),
    nom_mere character varying(100),
    prenom_mere character varying(100),
    active boolean DEFAULT true,
    expires_at timestamp without time zone DEFAULT (now() + '00:15:00'::interval),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT sessions_ussd_etape_check CHECK (((etape)::text = ANY ((ARRAY['choix_region'::character varying, 'choix_prefecture'::character varying, 'choix_sous_prefecture'::character varying, 'choix_localite'::character varying, 'saisie_nom_enfant'::character varying, 'saisie_sexe'::character varying, 'saisie_date_naissance'::character varying, 'saisie_nom_pere'::character varying, 'saisie_nom_mere'::character varying, 'confirmation'::character varying, 'termine'::character varying])::text[])))
);


--
-- Name: sessions_ussd_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_ussd_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_ussd_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_ussd_id_seq OWNED BY public.sessions_ussd.id;


--
-- Name: sous_prefectures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sous_prefectures (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    code character varying(10) NOT NULL,
    prefecture_id integer,
    numero_menu integer
);


--
-- Name: sous_prefectures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sous_prefectures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sous_prefectures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sous_prefectures_id_seq OWNED BY public.sous_prefectures.id;


--
-- Name: comptes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comptes ALTER COLUMN id SET DEFAULT nextval('public.comptes_id_seq'::regclass);


--
-- Name: departements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departements ALTER COLUMN id SET DEFAULT nextval('public.departements_id_seq'::regclass);


--
-- Name: districts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.districts ALTER COLUMN id SET DEFAULT nextval('public.districts_id_seq'::regclass);


--
-- Name: historique id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historique ALTER COLUMN id SET DEFAULT nextval('public.historique_id_seq'::regclass);


--
-- Name: localisation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localisation ALTER COLUMN id SET DEFAULT nextval('public.localisation_id_seq'::regclass);


--
-- Name: localites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localites ALTER COLUMN id SET DEFAULT nextval('public.localites_id_seq'::regclass);


--
-- Name: officiers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.officiers ALTER COLUMN id SET DEFAULT nextval('public.officiers_id_seq'::regclass);


--
-- Name: parents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parents ALTER COLUMN id SET DEFAULT nextval('public.parents_id_seq'::regclass);


--
-- Name: pre_enregistrements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_enregistrements ALTER COLUMN id SET DEFAULT nextval('public.pre_enregistrements_id_seq'::regclass);


--
-- Name: prefectures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prefectures ALTER COLUMN id SET DEFAULT nextval('public.prefectures_id_seq'::regclass);


--
-- Name: regions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions ALTER COLUMN id SET DEFAULT nextval('public.regions_id_seq'::regclass);


--
-- Name: sessions_ussd id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions_ussd ALTER COLUMN id SET DEFAULT nextval('public.sessions_ussd_id_seq'::regclass);


--
-- Name: sous_prefectures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sous_prefectures ALTER COLUMN id SET DEFAULT nextval('public.sous_prefectures_id_seq'::regclass);


--
-- Data for Name: comptes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comptes (id, nom, prenom, email, mot_de_passe, role, departement_id, actif, derniere_connexion, created_at) FROM stdin;
9	Admin	Master	admin@naissance-ci.gov.ci	$2b$12$sXXT2P/h7qpYUxCj7NskDeKB3DMhEYgDI2yCHEW9SMVBWmjqVzapu	admin_master	1	t	\N	2026-03-10 18:29:06.158156
4	Mairie	Man	mairie.man@gouv.ci	$2b$12$Y3EOnD9KGXwAIFhCVzmK6O/M8cYuHrOnMq3l1J1NtZJHPO3VZyKmy	mairie	7	t	\N	2026-03-10 13:11:01.25484
2	Mairie	Bouna	mairie.bouna@gouv.ci	$2b$12$XyXjMjeA3GPrBbGfMXWQBeUKdsAJxaqjq721RNpJlSf1KN5Y3oeha	mairie	3	t	\N	2026-03-10 13:11:01.25484
3	Mairie	Bondoukou	mairie.bondoukou@gouv.ci	$2b$12$Z7YQMskf13o10y3ROormfO2LGrK49EgsAat92TA96g7l5vozjTsVS	mairie	5	t	\N	2026-03-10 13:11:01.25484
5	Mairie	Odienné	mairie.odienne@gouv.ci	$2b$12$Vv8sLGSKWQ8q4/oImZ1c0OTjUyyb36FF13eHh6IArKDorZLJpq7si	mairie	9	t	\N	2026-03-10 13:11:01.25484
6	Mairie	Boundiali	mairie.boundiali@gouv.ci	$2b$12$8ubKhRfh.rSoGgQzS8Ieb.56F4XKN.TS0SZ42SjM/4PknE/bVAKA6	mairie	10	t	\N	2026-03-10 13:11:01.25484
7	Mairie	Tengréla	mairie.tengrela@gouv.ci	$2b$12$mBNNPdn1slm/6EaAFTyCduWiMYIGTpscUdp9BSpL.jCNJYd8Kc4aK	mairie	11	t	\N	2026-03-10 13:11:01.25484
8	Mairie	Dabakala	mairie.dabakala@gouv.ci	$2b$12$9FjFkyBl1eDwhMHeauMuH.0G.mIeDXboHKMpQHe/Tuube5l.bm4vG	mairie	12	t	\N	2026-03-10 13:11:01.25484
1	Mairie	Ferkessédougou	mairie.ferkessedougou@gouv.ci	$2b$12$eHgiVdCUBy0SmLryWQOaB.F7hCL64XcCaUwak9iHwmXHJgAtQZAje	mairie	1	t	\N	2026-03-10 13:11:01.25484
\.


--
-- Data for Name: departements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departements (id, nom, type, code_dept, district_id, region_id, prefecture_id, sous_prefecture_id, actif, created_at) FROM stdin;
1	Mairie de Ferkessédougou	mairie	DEPT-MAI-FER	\N	\N	1	\N	t	2026-03-10 13:11:01.19887
2	Sous-préfecture de Kong	sous_prefecture	DEPT-SP-KON	\N	\N	1	\N	t	2026-03-10 13:11:01.19887
3	Mairie de Bouna	mairie	DEPT-MAI-BNA	\N	\N	2	\N	t	2026-03-10 13:11:01.19887
4	Sous-préfecture de Doropo	sous_prefecture	DEPT-SP-DOR	\N	\N	2	\N	t	2026-03-10 13:11:01.19887
5	Mairie de Bondoukou	mairie	DEPT-MAI-BON	\N	\N	3	\N	t	2026-03-10 13:11:01.19887
6	Sous-préfecture de Tanda	sous_prefecture	DEPT-SP-TAN	\N	\N	3	\N	t	2026-03-10 13:11:01.19887
7	Mairie de Man	mairie	DEPT-MAI-MAN	\N	\N	4	\N	t	2026-03-10 13:11:01.19887
8	Sous-préfecture de Danané	sous_prefecture	DEPT-SP-DAN	\N	\N	4	\N	t	2026-03-10 13:11:01.19887
9	Mairie de Odienné	mairie	DEPT-MAI-ODI	\N	\N	7	\N	t	2026-03-10 13:11:01.19887
10	Mairie de Boundiali	mairie	DEPT-MAI-BND	\N	\N	12	\N	t	2026-03-10 13:11:01.19887
11	Mairie de Tengréla	mairie	DEPT-MAI-TEN	\N	\N	11	\N	t	2026-03-10 13:11:01.19887
12	Mairie de Dabakala	mairie	DEPT-MAI-DAB	\N	\N	9	\N	t	2026-03-10 13:11:01.19887
\.


--
-- Data for Name: districts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.districts (id, nom, code) FROM stdin;
\.


--
-- Data for Name: historique; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.historique (id, enregistrement_id, action, ancien_statut, nouveau_statut, effectue_par, commentaire, created_at) FROM stdin;
\.


--
-- Data for Name: localisation; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.localisation (id, village, district, region, pays) FROM stdin;
1	Korhogo Centre	Korhogo	Poro	Côte d'Ivoire
\.


--
-- Data for Name: localites; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.localites (id, nom, type, sous_prefecture_id, prefecture_id, region_id, latitude, longitude, population_estimee, actif, created_at, numero_menu) FROM stdin;
1	Ferkessédougou	ville	11	11	22	9.5936000	-5.1978000	103000	t	2026-03-10 12:42:02.013591	4
3	Lataha	village	11	11	22	9.5714000	-5.1523000	850	t	2026-03-10 12:42:02.013591	5
2	Nafoun	village	11	11	22	9.6102000	-5.2341000	1200	t	2026-03-10 12:42:02.013591	6
8	Siempurgo	campement	11	11	22	9.5512000	-5.1234000	180	t	2026-03-10 12:42:02.013591	7
4	Kaouara	village	12	11	22	9.6458000	-5.3012000	620	t	2026-03-10 12:42:02.013591	1
5	Koumbala	village	12	11	22	9.6789000	-5.2678000	780	t	2026-03-10 12:42:02.013591	2
10	Ouarigue	campement	14	11	22	9.4601000	-5.0789000	210	t	2026-03-10 12:42:02.013591	3
9	Togoniéré	village	14	11	22	9.4823000	-5.0156000	920	t	2026-03-10 12:42:02.013591	4
6	Kong	ville	15	11	22	9.1536000	-4.6142000	25000	t	2026-03-10 12:42:02.013591	1
7	Nambingué	village	15	11	22	9.2014000	-4.7823000	450	t	2026-03-10 12:42:02.013591	2
11	Bouna	ville	16	12	28	9.2691000	-3.0007000	45000	t	2026-03-10 12:42:02.013591	1
20	Koun	quartier_rural	16	12	28	9.2901000	-3.0234000	650	t	2026-03-10 12:42:02.013591	4
16	Lobo	campement	16	12	28	9.3145000	-3.0876000	320	t	2026-03-10 12:42:02.013591	5
12	Doropo	ville	17	12	28	9.8234000	-3.2341000	12000	t	2026-03-10 12:42:02.013591	2
17	Tankessé	village	17	12	28	9.9012000	-3.3678000	890	t	2026-03-10 12:42:02.013591	4
18	Gbiéké	campement	18	12	28	9.7234000	-3.1901000	250	t	2026-03-10 12:42:02.013591	1
13	Tehini	village	18	12	28	9.6712000	-3.1456000	3500	t	2026-03-10 12:42:02.013591	3
14	Nassian	village	19	12	28	8.9823000	-3.4512000	4200	t	2026-03-10 12:42:02.013591	3
19	Yalo	village	19	12	28	9.0456000	-3.5123000	1100	t	2026-03-10 12:42:02.013591	4
15	Sandégué	village	20	12	28	8.7634000	-3.2987000	2800	t	2026-03-10 12:42:02.013591	2
64	Ferkessédougou	ville	1	1	\N	9.5936000	-5.1978000	103000	t	2026-03-10 13:06:57.766458	1
66	Lataha	village	1	1	\N	9.5714000	-5.1523000	850	t	2026-03-10 13:06:57.766458	2
65	Nafoun	village	1	1	\N	9.6102000	-5.2341000	1200	t	2026-03-10 13:06:57.766458	3
71	Siempurgo	campement	1	1	\N	9.5512000	-5.1234000	180	t	2026-03-10 13:06:57.766458	4
67	Kaouara	village	2	1	\N	9.6458000	-5.3012000	620	t	2026-03-10 13:06:57.766458	1
68	Koumbala	village	2	1	\N	9.6789000	-5.2678000	780	t	2026-03-10 13:06:57.766458	2
73	Ouarigue	campement	4	1	\N	9.4601000	-5.0789000	210	t	2026-03-10 13:06:57.766458	1
72	Togoniéré	village	4	1	\N	9.4823000	-5.0156000	920	t	2026-03-10 13:06:57.766458	2
69	Kong	ville	5	1	\N	9.1536000	-4.6142000	25000	t	2026-03-10 13:06:57.766458	1
70	Nambingué	village	5	1	\N	9.2014000	-4.7823000	450	t	2026-03-10 13:06:57.766458	2
74	Bouna	ville	6	2	\N	9.2691000	-3.0007000	45000	t	2026-03-10 13:06:57.766458	1
83	Koun	quartier_rural	6	2	\N	9.2901000	-3.0234000	650	t	2026-03-10 13:06:57.766458	2
79	Lobo	campement	6	2	\N	9.3145000	-3.0876000	320	t	2026-03-10 13:06:57.766458	3
75	Doropo	ville	7	2	\N	9.8234000	-3.2341000	12000	t	2026-03-10 13:06:57.766458	1
80	Tankessé	village	7	2	\N	9.9012000	-3.3678000	890	t	2026-03-10 13:06:57.766458	2
81	Gbiéké	campement	8	2	\N	9.7234000	-3.1901000	250	t	2026-03-10 13:06:57.766458	1
76	Tehini	village	8	2	\N	9.6712000	-3.1456000	3500	t	2026-03-10 13:06:57.766458	2
77	Nassian	village	9	2	\N	8.9823000	-3.4512000	4200	t	2026-03-10 13:06:57.766458	1
82	Yalo	village	9	2	\N	9.0456000	-3.5123000	1100	t	2026-03-10 13:06:57.766458	2
78	Sandégué	village	10	2	\N	8.7634000	-3.2987000	2800	t	2026-03-10 13:06:57.766458	1
89	Amanvi	campement	11	3	\N	8.0123000	-2.8345000	280	t	2026-03-10 13:06:57.766458	1
84	Bondoukou	ville	11	3	\N	8.0408000	-2.7996000	80000	t	2026-03-10 13:06:57.766458	2
92	Brobo	quartier_rural	11	3	\N	8.0567000	-2.7678000	890	t	2026-03-10 13:06:57.766458	3
90	Tabagne	village	12	3	\N	7.9234000	-3.0901000	760	t	2026-03-10 13:06:57.766458	3
85	Transua	village	12	3	\N	7.8923000	-3.1234000	3200	t	2026-03-10 13:06:57.766458	4
86	Assuéfry	village	13	3	\N	7.6512000	-3.0456000	2100	t	2026-03-10 13:06:57.766458	1
93	Ntrasso	campement	13	3	\N	7.6789000	-3.0123000	190	t	2026-03-10 13:06:57.766458	2
91	Kouassi-Datékro	village	14	3	\N	7.4901000	-3.3012000	1350	t	2026-03-10 13:06:57.766458	1
87	Koun-Fao	village	14	3	\N	7.5234000	-3.2678000	4500	t	2026-03-10 13:06:57.766458	2
88	Tanda	ville	15	3	\N	7.8012000	-3.1789000	18000	t	2026-03-10 13:06:57.766458	3
102	Gbonné	quartier_rural	16	4	\N	7.4456000	-7.5234000	680	t	2026-03-10 13:06:57.766458	2
99	Kouibly	village	16	4	\N	7.2012000	-7.4789000	5200	t	2026-03-10 13:06:57.766458	3
94	Man	ville	16	4	\N	7.4125000	-7.5536000	150000	t	2026-03-10 13:06:57.766458	6
95	Danané	ville	17	4	\N	7.2634000	-8.1523000	55000	t	2026-03-10 13:06:57.766458	1
100	Logoualé	village	17	4	\N	7.1456000	-8.2345000	3800	t	2026-03-10 13:06:57.766458	3
101	Sipilou	campement	18	4	\N	7.0234000	-8.4567000	420	t	2026-03-10 13:06:57.766458	2
96	Zouan-Hounien	ville	18	4	\N	6.9234000	-8.5012000	22000	t	2026-03-10 13:06:57.766458	4
97	Biankouma	ville	19	4	\N	7.7345000	-7.6234000	18000	t	2026-03-10 13:06:57.766458	1
103	Blépleu	campement	19	4	\N	7.7901000	-7.6789000	310	t	2026-03-10 13:06:57.766458	2
98	Facobly	village	20	4	\N	7.3901000	-7.3456000	8500	t	2026-03-10 13:06:57.766458	1
26	Amanvi	campement	21	9	29	8.0123000	-2.8345000	280	t	2026-03-10 12:42:02.013591	1
21	Bondoukou	ville	21	9	29	8.0408000	-2.7996000	80000	t	2026-03-10 12:42:02.013591	2
29	Brobo	quartier_rural	21	9	29	8.0567000	-2.7678000	890	t	2026-03-10 12:42:02.013591	3
27	Tabagne	village	22	9	29	7.9234000	-3.0901000	760	t	2026-03-10 12:42:02.013591	1
22	Transua	village	22	9	29	7.8923000	-3.1234000	3200	t	2026-03-10 12:42:02.013591	2
23	Assuéfry	village	23	9	29	7.6512000	-3.0456000	2100	t	2026-03-10 12:42:02.013591	1
30	Ntrasso	campement	23	9	29	7.6789000	-3.0123000	190	t	2026-03-10 12:42:02.013591	2
28	Kouassi-Datékro	village	24	9	29	7.4901000	-3.3012000	1350	t	2026-03-10 12:42:02.013591	1
24	Koun-Fao	village	24	9	29	7.5234000	-3.2678000	4500	t	2026-03-10 12:42:02.013591	2
108	Gbéléban	village	25	7	\N	9.5678000	-7.5901000	3100	t	2026-03-10 13:06:57.766458	1
104	Odienné	ville	25	7	\N	9.5112000	-7.5634000	65000	t	2026-03-10 13:06:57.766458	2
25	Tanda	ville	25	9	29	7.8012000	-3.1789000	18000	t	2026-03-10 12:42:02.013591	3
39	Gbonné	quartier_rural	26	7	30	7.4456000	-7.5234000	680	t	2026-03-10 12:42:02.013591	1
36	Kouibly	village	26	7	30	7.2012000	-7.4789000	5200	t	2026-03-10 12:42:02.013591	2
105	Madinani	ville	26	7	\N	9.6234000	-7.3456000	15000	t	2026-03-10 13:06:57.766458	3
31	Man	ville	26	7	30	7.4125000	-7.5536000	150000	t	2026-03-10 12:42:02.013591	4
109	Minignan	village	26	7	\N	9.9234000	-7.2678000	2500	t	2026-03-10 13:06:57.766458	5
32	Danané	ville	27	7	30	7.2634000	-8.1523000	55000	t	2026-03-10 12:42:02.013591	1
106	Goulia	village	27	7	\N	9.8901000	-7.6789000	4200	t	2026-03-10 13:06:57.766458	2
110	Kaniasso	campement	27	7	\N	9.8456000	-7.7012000	380	t	2026-03-10 13:06:57.766458	3
37	Logoualé	village	27	7	30	7.1456000	-8.2345000	3800	t	2026-03-10 12:42:02.013591	4
107	Samatiguila	village	28	7	\N	9.7345000	-7.4123000	6800	t	2026-03-10 13:06:57.766458	1
38	Sipilou	campement	28	7	30	7.0234000	-8.4567000	420	t	2026-03-10 12:42:02.013591	2
33	Zouan-Hounien	ville	28	7	30	6.9234000	-8.5012000	22000	t	2026-03-10 12:42:02.013591	3
34	Biankouma	ville	29	7	30	7.7345000	-7.6234000	18000	t	2026-03-10 12:42:02.013591	1
40	Blépleu	campement	29	7	30	7.7901000	-7.6789000	310	t	2026-03-10 12:42:02.013591	2
111	Boundiali	ville	29	12	\N	9.5234000	-6.4789000	55000	t	2026-03-10 13:06:57.766458	3
114	Gbon	village	29	12	\N	9.5456000	-6.5012000	1800	t	2026-03-10 13:06:57.766458	4
35	Facobly	village	30	7	30	7.3901000	-7.3456000	8500	t	2026-03-10 12:42:02.013591	1
115	Kasséré	campement	30	12	\N	9.9123000	-6.3901000	420	t	2026-03-10 13:06:57.766458	2
112	Kouto	ville	30	12	\N	9.8901000	-6.4123000	18000	t	2026-03-10 13:06:57.766458	3
113	Sianhala	village	31	12	\N	9.6789000	-6.5234000	3200	t	2026-03-10 13:06:57.766458	1
118	Niellé	village	32	11	\N	10.5234000	-6.3789000	2800	t	2026-03-10 13:06:57.766458	1
116	Tengréla	ville	32	11	\N	10.4812000	-6.4034000	35000	t	2026-03-10 13:06:57.766458	2
117	Ouangolodougou	ville	33	11	\N	9.9678000	-5.1456000	22000	t	2026-03-10 13:06:57.766458	1
119	Papara	campement	33	11	\N	9.9901000	-5.1789000	350	t	2026-03-10 13:06:57.766458	2
120	Dabakala	ville	34	9	\N	8.3612000	-4.4323000	28000	t	2026-03-10 13:06:57.766458	1
126	Djamala	campement	34	9	\N	8.3456000	-4.5012000	290	t	2026-03-10 13:06:57.766458	2
123	Fronan	village	34	9	\N	8.3901000	-4.4678000	1500	t	2026-03-10 13:06:57.766458	3
45	Gbéléban	village	35	10	24	9.5678000	-7.5901000	3100	t	2026-03-10 12:42:02.013591	1
121	Niakara	ville	35	9	\N	8.7234000	-4.7012000	12000	t	2026-03-10 13:06:57.766458	2
41	Odienné	ville	35	10	24	9.5112000	-7.5634000	65000	t	2026-03-10 12:42:02.013591	3
124	Satama-Sokoura	village	35	9	\N	8.7567000	-4.6789000	980	t	2026-03-10 13:06:57.766458	4
42	Madinani	ville	36	10	24	9.6234000	-7.3456000	15000	t	2026-03-10 12:42:02.013591	1
46	Minignan	village	36	10	24	9.9234000	-7.2678000	2500	t	2026-03-10 12:42:02.013591	2
122	Niakaramandougou	ville	36	9	\N	8.6634000	-5.2901000	35000	t	2026-03-10 13:06:57.766458	3
125	Tafiré	village	36	9	\N	8.7012000	-5.1234000	2200	t	2026-03-10 13:06:57.766458	4
43	Goulia	village	37	10	24	9.8901000	-7.6789000	4200	t	2026-03-10 12:42:02.013591	1
47	Kaniasso	campement	37	10	24	9.8456000	-7.7012000	380	t	2026-03-10 12:42:02.013591	2
44	Samatiguila	village	38	10	24	9.7345000	-7.4123000	6800	t	2026-03-10 12:42:02.013591	1
48	Boundiali	ville	39	22	21	9.5234000	-6.4789000	55000	t	2026-03-10 12:42:02.013591	1
51	Gbon	village	39	22	21	9.5456000	-6.5012000	1800	t	2026-03-10 12:42:02.013591	2
52	Kasséré	campement	40	22	21	9.9123000	-6.3901000	420	t	2026-03-10 12:42:02.013591	1
49	Kouto	ville	40	22	21	9.8901000	-6.4123000	18000	t	2026-03-10 12:42:02.013591	2
50	Sianhala	village	41	22	21	9.6789000	-6.5234000	3200	t	2026-03-10 12:42:02.013591	1
55	Niellé	village	42	21	21	10.5234000	-6.3789000	2800	t	2026-03-10 12:42:02.013591	1
53	Tengréla	ville	42	21	21	10.4812000	-6.4034000	35000	t	2026-03-10 12:42:02.013591	2
54	Ouangolodougou	ville	43	21	21	9.9678000	-5.1456000	22000	t	2026-03-10 12:42:02.013591	1
56	Papara	campement	43	21	21	9.9901000	-5.1789000	350	t	2026-03-10 12:42:02.013591	2
57	Dabakala	ville	44	19	18	8.3612000	-4.4323000	28000	t	2026-03-10 12:42:02.013591	1
63	Djamala	campement	44	19	18	8.3456000	-4.5012000	290	t	2026-03-10 12:42:02.013591	2
60	Fronan	village	44	19	18	8.3901000	-4.4678000	1500	t	2026-03-10 12:42:02.013591	3
58	Niakara	ville	45	19	18	8.7234000	-4.7012000	12000	t	2026-03-10 12:42:02.013591	1
61	Satama-Sokoura	village	45	19	18	8.7567000	-4.6789000	980	t	2026-03-10 12:42:02.013591	2
59	Niakaramandougou	ville	46	19	18	8.6634000	-5.2901000	35000	t	2026-03-10 12:42:02.013591	1
62	Tafiré	village	46	19	18	8.7012000	-5.1234000	2200	t	2026-03-10 12:42:02.013591	2
127	Ferkessédougou	ville	1	1	\N	9.5936000	-5.1978000	103000	t	2026-03-10 13:11:01.086539	\N
128	Nafoun	village	1	1	\N	9.6102000	-5.2341000	1200	t	2026-03-10 13:11:01.086539	\N
129	Lataha	village	1	1	\N	9.5714000	-5.1523000	850	t	2026-03-10 13:11:01.086539	\N
130	Kaouara	village	2	1	\N	9.6458000	-5.3012000	620	t	2026-03-10 13:11:01.086539	\N
131	Koumbala	village	2	1	\N	9.6789000	-5.2678000	780	t	2026-03-10 13:11:01.086539	\N
132	Kong	ville	5	1	\N	9.1536000	-4.6142000	25000	t	2026-03-10 13:11:01.086539	\N
133	Nambingué	village	5	1	\N	9.2014000	-4.7823000	450	t	2026-03-10 13:11:01.086539	\N
134	Siempurgo	campement	1	1	\N	9.5512000	-5.1234000	180	t	2026-03-10 13:11:01.086539	\N
135	Togoniéré	village	4	1	\N	9.4823000	-5.0156000	920	t	2026-03-10 13:11:01.086539	\N
136	Ouarigue	campement	4	1	\N	9.4601000	-5.0789000	210	t	2026-03-10 13:11:01.086539	\N
137	Bouna	ville	6	2	\N	9.2691000	-3.0007000	45000	t	2026-03-10 13:11:01.086539	\N
138	Doropo	ville	7	2	\N	9.8234000	-3.2341000	12000	t	2026-03-10 13:11:01.086539	\N
139	Tehini	village	8	2	\N	9.6712000	-3.1456000	3500	t	2026-03-10 13:11:01.086539	\N
140	Nassian	village	9	2	\N	8.9823000	-3.4512000	4200	t	2026-03-10 13:11:01.086539	\N
141	Sandégué	village	10	2	\N	8.7634000	-3.2987000	2800	t	2026-03-10 13:11:01.086539	\N
142	Lobo	campement	6	2	\N	9.3145000	-3.0876000	320	t	2026-03-10 13:11:01.086539	\N
143	Tankessé	village	7	2	\N	9.9012000	-3.3678000	890	t	2026-03-10 13:11:01.086539	\N
144	Gbiéké	campement	8	2	\N	9.7234000	-3.1901000	250	t	2026-03-10 13:11:01.086539	\N
145	Yalo	village	9	2	\N	9.0456000	-3.5123000	1100	t	2026-03-10 13:11:01.086539	\N
146	Koun	quartier_rural	6	2	\N	9.2901000	-3.0234000	650	t	2026-03-10 13:11:01.086539	\N
147	Bondoukou	ville	11	3	\N	8.0408000	-2.7996000	80000	t	2026-03-10 13:11:01.086539	\N
148	Transua	village	12	3	\N	7.8923000	-3.1234000	3200	t	2026-03-10 13:11:01.086539	\N
149	Assuéfry	village	13	3	\N	7.6512000	-3.0456000	2100	t	2026-03-10 13:11:01.086539	\N
150	Koun-Fao	village	14	3	\N	7.5234000	-3.2678000	4500	t	2026-03-10 13:11:01.086539	\N
151	Tanda	ville	15	3	\N	7.8012000	-3.1789000	18000	t	2026-03-10 13:11:01.086539	\N
152	Amanvi	campement	11	3	\N	8.0123000	-2.8345000	280	t	2026-03-10 13:11:01.086539	\N
153	Tabagne	village	12	3	\N	7.9234000	-3.0901000	760	t	2026-03-10 13:11:01.086539	\N
154	Kouassi-Datékro	village	14	3	\N	7.4901000	-3.3012000	1350	t	2026-03-10 13:11:01.086539	\N
155	Brobo	quartier_rural	11	3	\N	8.0567000	-2.7678000	890	t	2026-03-10 13:11:01.086539	\N
156	Ntrasso	campement	13	3	\N	7.6789000	-3.0123000	190	t	2026-03-10 13:11:01.086539	\N
157	Man	ville	16	4	\N	7.4125000	-7.5536000	150000	t	2026-03-10 13:11:01.086539	\N
158	Danané	ville	17	4	\N	7.2634000	-8.1523000	55000	t	2026-03-10 13:11:01.086539	\N
159	Zouan-Hounien	ville	18	4	\N	6.9234000	-8.5012000	22000	t	2026-03-10 13:11:01.086539	\N
160	Biankouma	ville	19	4	\N	7.7345000	-7.6234000	18000	t	2026-03-10 13:11:01.086539	\N
161	Facobly	village	20	4	\N	7.3901000	-7.3456000	8500	t	2026-03-10 13:11:01.086539	\N
162	Kouibly	village	16	4	\N	7.2012000	-7.4789000	5200	t	2026-03-10 13:11:01.086539	\N
163	Logoualé	village	17	4	\N	7.1456000	-8.2345000	3800	t	2026-03-10 13:11:01.086539	\N
164	Sipilou	campement	18	4	\N	7.0234000	-8.4567000	420	t	2026-03-10 13:11:01.086539	\N
165	Gbonné	quartier_rural	16	4	\N	7.4456000	-7.5234000	680	t	2026-03-10 13:11:01.086539	\N
166	Blépleu	campement	19	4	\N	7.7901000	-7.6789000	310	t	2026-03-10 13:11:01.086539	\N
167	Odienné	ville	25	7	\N	9.5112000	-7.5634000	65000	t	2026-03-10 13:11:01.086539	\N
168	Madinani	ville	26	7	\N	9.6234000	-7.3456000	15000	t	2026-03-10 13:11:01.086539	\N
169	Goulia	village	27	7	\N	9.8901000	-7.6789000	4200	t	2026-03-10 13:11:01.086539	\N
170	Samatiguila	village	28	7	\N	9.7345000	-7.4123000	6800	t	2026-03-10 13:11:01.086539	\N
171	Gbéléban	village	25	7	\N	9.5678000	-7.5901000	3100	t	2026-03-10 13:11:01.086539	\N
172	Minignan	village	26	7	\N	9.9234000	-7.2678000	2500	t	2026-03-10 13:11:01.086539	\N
173	Kaniasso	campement	27	7	\N	9.8456000	-7.7012000	380	t	2026-03-10 13:11:01.086539	\N
174	Boundiali	ville	29	12	\N	9.5234000	-6.4789000	55000	t	2026-03-10 13:11:01.086539	\N
175	Kouto	ville	30	12	\N	9.8901000	-6.4123000	18000	t	2026-03-10 13:11:01.086539	\N
176	Sianhala	village	31	12	\N	9.6789000	-6.5234000	3200	t	2026-03-10 13:11:01.086539	\N
177	Gbon	village	29	12	\N	9.5456000	-6.5012000	1800	t	2026-03-10 13:11:01.086539	\N
178	Kasséré	campement	30	12	\N	9.9123000	-6.3901000	420	t	2026-03-10 13:11:01.086539	\N
179	Tengréla	ville	32	11	\N	10.4812000	-6.4034000	35000	t	2026-03-10 13:11:01.086539	\N
180	Ouangolodougou	ville	33	11	\N	9.9678000	-5.1456000	22000	t	2026-03-10 13:11:01.086539	\N
181	Niellé	village	32	11	\N	10.5234000	-6.3789000	2800	t	2026-03-10 13:11:01.086539	\N
182	Papara	campement	33	11	\N	9.9901000	-5.1789000	350	t	2026-03-10 13:11:01.086539	\N
183	Dabakala	ville	34	9	\N	8.3612000	-4.4323000	28000	t	2026-03-10 13:11:01.086539	\N
184	Niakara	ville	35	9	\N	8.7234000	-4.7012000	12000	t	2026-03-10 13:11:01.086539	\N
185	Niakaramandougou	ville	36	9	\N	8.6634000	-5.2901000	35000	t	2026-03-10 13:11:01.086539	\N
186	Fronan	village	34	9	\N	8.3901000	-4.4678000	1500	t	2026-03-10 13:11:01.086539	\N
187	Satama-Sokoura	village	35	9	\N	8.7567000	-4.6789000	980	t	2026-03-10 13:11:01.086539	\N
188	Tafiré	village	36	9	\N	8.7012000	-5.1234000	2200	t	2026-03-10 13:11:01.086539	\N
189	Djamala	campement	34	9	\N	8.3456000	-4.5012000	290	t	2026-03-10 13:11:01.086539	\N
\.


--
-- Data for Name: officiers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.officiers (id, nom, prenom, matricule, departement_id, actif, created_at) FROM stdin;
\.


--
-- Data for Name: parents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parents (id, nom_pere, prenom_pere, telephone_pere, nom_mere, prenom_mere, telephone_mere, sous_prefecture_id, created_at) FROM stdin;
\.


--
-- Data for Name: postgresql_driver; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.postgresql_driver  FROM stdin;
\.


--
-- Data for Name: pre_enregistrements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pre_enregistrements (id, numero_recu, nom_enfant, prenom_enfant, sexe, date_naissance, heure_naissance, lieu_naissance, parents_id, sous_prefecture_id, departement_id, code_ussd, telephone_declarant, statut, officier_id, date_validation, motif_rejet, created_at, updated_at, localite_id) FROM stdin;
\.


--
-- Data for Name: prefectures; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.prefectures (id, nom, code, region_id, numero_menu) FROM stdin;
1	Ferkessédougou	P-FER	\N	\N
2	Bouna	P-BNA	\N	\N
3	Bondoukou	P-BON	\N	\N
4	Man	P-MAN	\N	\N
5	Séguéla	P-SEG	\N	\N
6	Touba	P-TOU	\N	\N
7	Odienné	P-ODI	\N	\N
8	Minignan	P-MIN	\N	\N
9	Dabakala	P-DAB	\N	\N
10	Katiola	P-KAT	\N	\N
11	Tengréla	P-TEN	\N	\N
12	Boundiali	P-BND	\N	\N
13	Mankono	P-MAN2	\N	\N
14	Béoumi	P-BEO	\N	\N
15	Sakassou	P-SAK	\N	\N
\.


--
-- Data for Name: regions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.regions (id, nom, code, district_id, numero_menu) FROM stdin;
\.


--
-- Data for Name: sessions_ussd; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sessions_ussd (id, telephone, etape, region_id, prefecture_id, sous_prefecture_id, localite_id, nom_enfant, prenom_enfant, sexe, date_naissance, nom_pere, prenom_pere, nom_mere, prenom_mere, active, expires_at, created_at, updated_at) FROM stdin;
1	+22507111111	choix_localite	\N	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	2026-03-10 13:24:03.398182	2026-03-10 13:09:03.398182	2026-03-10 13:15:48.685168
2	+22507111111	choix_localite	\N	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	2026-03-10 13:24:48.18172	2026-03-10 13:09:48.18172	2026-03-10 13:15:48.685168
3	+22507111111	choix_localite	\N	1	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	2026-03-10 13:30:48.500241	2026-03-10 13:15:48.500241	2026-03-10 13:15:48.685168
\.


--
-- Data for Name: sous_prefectures; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sous_prefectures (id, nom, code, prefecture_id, numero_menu) FROM stdin;
1	Ferkessédougou Centre	SP-FER-C	1	\N
2	Koumbala	SP-FER-KOU	1	\N
3	Niakaramandougou	SP-FER-NIA	1	\N
4	Togoniéré	SP-FER-TOG	1	\N
5	Kong	SP-FER-KON	1	\N
6	Bouna Centre	SP-BNA-C	2	\N
7	Doropo	SP-BNA-DOR	2	\N
8	Tehini	SP-BNA-TEH	2	\N
9	Nassian	SP-BNA-NAS	2	\N
10	Sandégué	SP-BNA-SAN	2	\N
11	Bondoukou Centre	SP-BON-C	3	\N
12	Transua	SP-BON-TRA	3	\N
13	Assuéfry	SP-BON-ASS	3	\N
14	Koun-Fao	SP-BON-KOU	3	\N
15	Tanda	SP-BON-TAN	3	\N
16	Man Centre	SP-MAN-C	4	\N
17	Danané	SP-MAN-DAN	4	\N
18	Zouan-Hounien	SP-MAN-ZOU	4	\N
19	Biankouma	SP-MAN-BIA	4	\N
20	Facobly	SP-MAN-FAC	4	\N
21	Séguéla Centre	SP-SEG-C	5	\N
22	Vavoua	SP-SEG-VAV	5	\N
23	Kani	SP-SEG-KAN	5	\N
24	Kounahiri	SP-SEG-KOU	5	\N
25	Odienné Centre	SP-ODI-C	7	\N
26	Madinani	SP-ODI-MAD	7	\N
27	Goulia	SP-ODI-GOU	7	\N
28	Samatiguila	SP-ODI-SAM	7	\N
29	Boundiali Centre	SP-BND-C	12	\N
30	Kouto	SP-BND-KOU	12	\N
31	Sianhala	SP-BND-SIA	12	\N
32	Tengréla Centre	SP-TEN-C	11	\N
33	Ouangolodougou	SP-TEN-OUA	11	\N
34	Dabakala Centre	SP-DAB-C	9	\N
35	Niakara	SP-DAB-NIA	9	\N
36	Niakaramandougou	SP-DAB-NM	9	\N
\.


--
-- Name: comptes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.comptes_id_seq', 10, true);


--
-- Name: departements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.departements_id_seq', 12, true);


--
-- Name: districts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.districts_id_seq', 1, false);


--
-- Name: historique_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.historique_id_seq', 1, false);


--
-- Name: localisation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.localisation_id_seq', 1, true);


--
-- Name: localites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.localites_id_seq', 189, true);


--
-- Name: officiers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.officiers_id_seq', 1, false);


--
-- Name: parents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.parents_id_seq', 1, false);


--
-- Name: pre_enregistrements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pre_enregistrements_id_seq', 2, true);


--
-- Name: prefectures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.prefectures_id_seq', 15, true);


--
-- Name: recu_sequence; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recu_sequence', 2, true);


--
-- Name: regions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.regions_id_seq', 1, false);


--
-- Name: sessions_ussd_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sessions_ussd_id_seq', 3, true);


--
-- Name: sous_prefectures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sous_prefectures_id_seq', 36, true);


--
-- Name: comptes comptes_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comptes
    ADD CONSTRAINT comptes_email_key UNIQUE (email);


--
-- Name: comptes comptes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comptes
    ADD CONSTRAINT comptes_pkey PRIMARY KEY (id);


--
-- Name: departements departements_code_dept_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departements
    ADD CONSTRAINT departements_code_dept_key UNIQUE (code_dept);


--
-- Name: departements departements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departements
    ADD CONSTRAINT departements_pkey PRIMARY KEY (id);


--
-- Name: districts districts_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_code_key UNIQUE (code);


--
-- Name: districts districts_nom_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_nom_key UNIQUE (nom);


--
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- Name: historique historique_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historique
    ADD CONSTRAINT historique_pkey PRIMARY KEY (id);


--
-- Name: localisation localisation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localisation
    ADD CONSTRAINT localisation_pkey PRIMARY KEY (id);


--
-- Name: localites localites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localites
    ADD CONSTRAINT localites_pkey PRIMARY KEY (id);


--
-- Name: officiers officiers_matricule_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.officiers
    ADD CONSTRAINT officiers_matricule_key UNIQUE (matricule);


--
-- Name: officiers officiers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.officiers
    ADD CONSTRAINT officiers_pkey PRIMARY KEY (id);


--
-- Name: parents parents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_pkey PRIMARY KEY (id);


--
-- Name: pre_enregistrements pre_enregistrements_numero_recu_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_enregistrements
    ADD CONSTRAINT pre_enregistrements_numero_recu_key UNIQUE (numero_recu);


--
-- Name: pre_enregistrements pre_enregistrements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_enregistrements
    ADD CONSTRAINT pre_enregistrements_pkey PRIMARY KEY (id);


--
-- Name: prefectures prefectures_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prefectures
    ADD CONSTRAINT prefectures_code_key UNIQUE (code);


--
-- Name: prefectures prefectures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prefectures
    ADD CONSTRAINT prefectures_pkey PRIMARY KEY (id);


--
-- Name: regions regions_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_code_key UNIQUE (code);


--
-- Name: regions regions_nom_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_nom_key UNIQUE (nom);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- Name: sessions_ussd sessions_ussd_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions_ussd
    ADD CONSTRAINT sessions_ussd_pkey PRIMARY KEY (id);


--
-- Name: sous_prefectures sous_prefectures_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sous_prefectures
    ADD CONSTRAINT sous_prefectures_code_key UNIQUE (code);


--
-- Name: sous_prefectures sous_prefectures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sous_prefectures
    ADD CONSTRAINT sous_prefectures_pkey PRIMARY KEY (id);


--
-- Name: idx_departement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_departement ON public.pre_enregistrements USING btree (departement_id);


--
-- Name: idx_localite; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_localite ON public.pre_enregistrements USING btree (localite_id);


--
-- Name: idx_localite_prefecture; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_localite_prefecture ON public.localites USING btree (prefecture_id);


--
-- Name: idx_localite_region; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_localite_region ON public.localites USING btree (region_id);


--
-- Name: idx_localite_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_localite_type ON public.localites USING btree (type);


--
-- Name: idx_numero_recu; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_numero_recu ON public.pre_enregistrements USING btree (numero_recu);


--
-- Name: idx_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_role ON public.comptes USING btree (role);


--
-- Name: idx_session_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_session_active ON public.sessions_ussd USING btree (active);


--
-- Name: idx_session_telephone; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_session_telephone ON public.sessions_ussd USING btree (telephone);


--
-- Name: idx_statut; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_statut ON public.pre_enregistrements USING btree (statut);


--
-- Name: pre_enregistrements trigger_recu; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_recu BEFORE INSERT ON public.pre_enregistrements FOR EACH ROW EXECUTE FUNCTION public.generer_numero_recu();


--
-- Name: comptes comptes_departement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comptes
    ADD CONSTRAINT comptes_departement_id_fkey FOREIGN KEY (departement_id) REFERENCES public.departements(id);


--
-- Name: departements departements_district_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departements
    ADD CONSTRAINT departements_district_id_fkey FOREIGN KEY (district_id) REFERENCES public.districts(id);


--
-- Name: departements departements_prefecture_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departements
    ADD CONSTRAINT departements_prefecture_id_fkey FOREIGN KEY (prefecture_id) REFERENCES public.prefectures(id);


--
-- Name: departements departements_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departements
    ADD CONSTRAINT departements_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id);


--
-- Name: departements departements_sous_prefecture_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departements
    ADD CONSTRAINT departements_sous_prefecture_id_fkey FOREIGN KEY (sous_prefecture_id) REFERENCES public.sous_prefectures(id);


--
-- Name: historique historique_enregistrement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historique
    ADD CONSTRAINT historique_enregistrement_id_fkey FOREIGN KEY (enregistrement_id) REFERENCES public.pre_enregistrements(id);


--
-- Name: officiers officiers_departement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.officiers
    ADD CONSTRAINT officiers_departement_id_fkey FOREIGN KEY (departement_id) REFERENCES public.departements(id);


--
-- Name: parents parents_sous_prefecture_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_sous_prefecture_id_fkey FOREIGN KEY (sous_prefecture_id) REFERENCES public.sous_prefectures(id);


--
-- Name: pre_enregistrements pre_enregistrements_departement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_enregistrements
    ADD CONSTRAINT pre_enregistrements_departement_id_fkey FOREIGN KEY (departement_id) REFERENCES public.departements(id);


--
-- Name: pre_enregistrements pre_enregistrements_localite_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_enregistrements
    ADD CONSTRAINT pre_enregistrements_localite_id_fkey FOREIGN KEY (localite_id) REFERENCES public.localites(id);


--
-- Name: pre_enregistrements pre_enregistrements_officier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_enregistrements
    ADD CONSTRAINT pre_enregistrements_officier_id_fkey FOREIGN KEY (officier_id) REFERENCES public.officiers(id);


--
-- Name: pre_enregistrements pre_enregistrements_parents_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_enregistrements
    ADD CONSTRAINT pre_enregistrements_parents_id_fkey FOREIGN KEY (parents_id) REFERENCES public.parents(id);


--
-- Name: pre_enregistrements pre_enregistrements_sous_prefecture_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pre_enregistrements
    ADD CONSTRAINT pre_enregistrements_sous_prefecture_id_fkey FOREIGN KEY (sous_prefecture_id) REFERENCES public.sous_prefectures(id);


--
-- Name: prefectures prefectures_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prefectures
    ADD CONSTRAINT prefectures_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id);


--
-- Name: regions regions_district_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_district_id_fkey FOREIGN KEY (district_id) REFERENCES public.districts(id);


--
-- Name: sessions_ussd sessions_ussd_localite_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions_ussd
    ADD CONSTRAINT sessions_ussd_localite_id_fkey FOREIGN KEY (localite_id) REFERENCES public.localites(id);


--
-- Name: sous_prefectures sous_prefectures_prefecture_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sous_prefectures
    ADD CONSTRAINT sous_prefectures_prefecture_id_fkey FOREIGN KEY (prefecture_id) REFERENCES public.prefectures(id);


--
-- PostgreSQL database dump complete
--

\unrestrict mifFuKpHTaUhjOAIL7HUon0r6F1Nd7vhIL8vDFnjK9OchlCQOJ4fh1GtkMRMP0T

