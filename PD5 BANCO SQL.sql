-- =========================================================
-- PROJETO 1 - BANCO DE DADOS II
-- SISTEMA DE E-COMMERCE
-- ETAPA 5 - SCRIPT DE CRIACAO DO BANCO + CARGA DE TESTE
-- =========================================================

-- =========================================================
-- 1. CRIACAO DO BANCO
-- =========================================================
DROP DATABASE IF EXISTS ecommerce_puc;
CREATE DATABASE ecommerce_puc
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE ecommerce_puc;

-- =========================================================
-- 2. CRIACAO DAS TABELAS
-- =========================================================

-- ---------------------------------------------------------
-- TABELA: cliente
-- Armazena os dados cadastrais dos clientes
-- ---------------------------------------------------------
CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    cpf VARCHAR(14) NOT NULL UNIQUE,
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'ATIVO'
);

-- ---------------------------------------------------------
-- TABELA: endereco
-- Armazena os enderecos vinculados ao cliente
-- ---------------------------------------------------------
CREATE TABLE endereco (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    logradouro VARCHAR(120) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(80),
    bairro VARCHAR(80) NOT NULL,
    cidade VARCHAR(80) NOT NULL,
    estado CHAR(2) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    tipo_endereco VARCHAR(20) NOT NULL,
    CONSTRAINT fk_endereco_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

-- ---------------------------------------------------------
-- TABELA: categoria
-- Classifica os produtos do catalogo
-- ---------------------------------------------------------
CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE,
    descricao VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'ATIVA'
);

-- ---------------------------------------------------------
-- TABELA: produto
-- Armazena os produtos vendidos no e-commerce
-- ---------------------------------------------------------
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome VARCHAR(120) NOT NULL,
    descricao TEXT,
    sku VARCHAR(50) NOT NULL UNIQUE,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_produto_categoria
        FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

-- ---------------------------------------------------------
-- TABELA: fornecedor
-- Armazena os fornecedores dos produtos
-- ---------------------------------------------------------
CREATE TABLE fornecedor (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(120) NOT NULL,
    nome_fantasia VARCHAR(120),
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    email VARCHAR(120),
    telefone VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'ATIVO'
);

-- ---------------------------------------------------------
-- TABELA: produto_fornecedor
-- Tabela associativa entre produto e fornecedor
-- ---------------------------------------------------------
CREATE TABLE produto_fornecedor (
    id_produto INT NOT NULL,
    id_fornecedor INT NOT NULL,
    custo_fornecimento DECIMAL(10,2) NOT NULL,
    prazo_reposicao_dias INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_produto, id_fornecedor),
    CONSTRAINT fk_pf_produto
        FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
    CONSTRAINT fk_pf_fornecedor
        FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor)
);

-- ---------------------------------------------------------
-- TABELA: carrinho
-- Representa o carrinho de compras do cliente
-- ---------------------------------------------------------
CREATE TABLE carrinho (
    id_carrinho INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_criacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'ABERTO',
    CONSTRAINT fk_carrinho_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

-- ---------------------------------------------------------
-- TABELA: item_carrinho
-- Armazena os itens adicionados ao carrinho
-- ---------------------------------------------------------
CREATE TABLE item_carrinho (
    id_item_carrinho INT AUTO_INCREMENT PRIMARY KEY,
    id_carrinho INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_item_carrinho_carrinho
        FOREIGN KEY (id_carrinho) REFERENCES carrinho(id_carrinho),
    CONSTRAINT fk_item_carrinho_produto
        FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

-- ---------------------------------------------------------
-- TABELA: pedido
-- Armazena os pedidos finalizados pelos clientes
-- ---------------------------------------------------------
CREATE TABLE pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_endereco_entrega INT NOT NULL,
    data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'CRIADO',
    valor_produtos DECIMAL(10,2) NOT NULL DEFAULT 0,
    valor_frete DECIMAL(10,2) NOT NULL DEFAULT 0,
    valor_desconto DECIMAL(10,2) NOT NULL DEFAULT 0,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_pedido_endereco
        FOREIGN KEY (id_endereco_entrega) REFERENCES endereco(id_endereco)
);

-- ---------------------------------------------------------
-- TABELA: item_pedido
-- Detalha os produtos comprados em cada pedido
-- ---------------------------------------------------------
CREATE TABLE item_pedido (
    id_item_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    desconto_item DECIMAL(10,2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_item_pedido_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
    CONSTRAINT fk_item_pedido_produto
        FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

-- ---------------------------------------------------------
-- TABELA: pagamento
-- Armazena os dados do pagamento do pedido
-- Relacao 1:1 com pedido
-- ---------------------------------------------------------
CREATE TABLE pagamento (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE,
    forma_pagamento VARCHAR(20) NOT NULL,
    status_pagamento VARCHAR(20) NOT NULL,
    valor_pago DECIMAL(10,2) NOT NULL,
    data_pagamento DATETIME,
    codigo_transacao VARCHAR(80),
    CONSTRAINT fk_pagamento_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
);

-- ---------------------------------------------------------
-- TABELA: entrega
-- Armazena os dados logisticos da entrega
-- Relacao 1:1 com pedido
-- ---------------------------------------------------------
CREATE TABLE entrega (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE,
    transportadora VARCHAR(100) NOT NULL,
    codigo_rastreio VARCHAR(80),
    status_entrega VARCHAR(20) NOT NULL,
    data_envio DATETIME,
    data_entrega_prevista DATETIME,
    data_entrega_realizada DATETIME,
    CONSTRAINT fk_entrega_pedido
        FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
);

-- =========================================================
-- 3. CARGA DE DADOS DE TESTE
-- =========================================================

-- ---------------------------------------------------------
-- CLIENTES
-- ---------------------------------------------------------
INSERT INTO cliente (nome, email, telefone, cpf, status) VALUES
('Ana Souza', 'ana@email.com', '11999990001', '111.111.111-11', 'ATIVO'),
('Bruno Lima', 'bruno@email.com', '11999990002', '222.222.222-22', 'ATIVO'),
('Carla Mendes', 'carla@email.com', '11999990003', '333.333.333-33', 'ATIVO'),
('Diego Alves', 'diego@email.com', '11999990004', '444.444.444-44', 'ATIVO');

-- ---------------------------------------------------------
-- ENDERECOS
-- ---------------------------------------------------------
INSERT INTO endereco (id_cliente, logradouro, numero, complemento, bairro, cidade, estado, cep, tipo_endereco) VALUES
(1, 'Rua das Flores', '100', 'Apto 12', 'Centro', 'São Paulo', 'SP', '01000-000', 'AMBOS'),
(2, 'Avenida Brasil', '250', NULL, 'Mooca', 'São Paulo', 'SP', '02000-000', 'ENTREGA'),
(3, 'Rua Verde', '300', 'Casa', 'Jardins', 'São Paulo', 'SP', '03000-000', 'ENTREGA'),
(4, 'Rua Azul', '450', NULL, 'Tatuapé', 'São Paulo', 'SP', '04000-000', 'AMBOS');

-- ---------------------------------------------------------
-- CATEGORIAS
-- ---------------------------------------------------------
INSERT INTO categoria (nome, descricao, status) VALUES
('Eletrônicos', 'Produtos eletrônicos em geral', 'ATIVA'),
('Informática', 'Produtos de informática', 'ATIVA'),
('Acessórios', 'Acessórios diversos', 'ATIVA'),
('Periféricos', 'Periféricos para computador', 'ATIVA');

-- ---------------------------------------------------------
-- PRODUTOS
-- ---------------------------------------------------------
INSERT INTO produto (id_categoria, nome, descricao, sku, preco, estoque, ativo) VALUES
(1, 'Fone Bluetooth', 'Fone de ouvido sem fio', 'SKU001', 199.90, 50, TRUE),
(2, 'Notebook Gamer', 'Notebook com alto desempenho', 'SKU002', 4599.90, 10, TRUE),
(4, 'Mouse Gamer', 'Mouse com RGB e alta precisão', 'SKU003', 149.90, 80, TRUE),
(4, 'Teclado Mecânico', 'Teclado gamer com switch azul', 'SKU004', 349.90, 35, TRUE),
(3, 'Mousepad Extra Grande', 'Mousepad de grande dimensão', 'SKU005', 79.90, 100, TRUE),
(2, 'Monitor 24 Polegadas', 'Monitor Full HD 24"', 'SKU006', 899.90, 20, TRUE);

-- ---------------------------------------------------------
-- FORNECEDORES
-- ---------------------------------------------------------
INSERT INTO fornecedor (razao_social, nome_fantasia, cnpj, email, telefone, status) VALUES
('Tech Distribuidora LTDA', 'TechDist', '11.111.111/0001-11', 'contato@techdist.com', '1133334444', 'ATIVO'),
('Info Supply SA', 'InfoSupply', '22.222.222/0001-22', 'vendas@infosupply.com', '1144445555', 'ATIVO'),
('Mega Hardware LTDA', 'MegaHardware', '33.333.333/0001-33', 'comercial@megahardware.com', '1155556666', 'ATIVO');

-- ---------------------------------------------------------
-- RELACAO PRODUTO x FORNECEDOR
-- ---------------------------------------------------------
INSERT INTO produto_fornecedor (id_produto, id_fornecedor, custo_fornecimento, prazo_reposicao_dias) VALUES
(1, 1, 120.00, 7),
(2, 3, 3900.00, 15),
(3, 2, 90.00, 5),
(4, 2, 220.00, 8),
(5, 1, 35.00, 4),
(6, 3, 650.00, 10);

-- ---------------------------------------------------------
-- CARRINHOS
-- ---------------------------------------------------------
INSERT INTO carrinho (id_cliente, status) VALUES
(1, 'ABERTO'),
(2, 'FINALIZADO'),
(3, 'ABANDONADO'),
(4, 'FINALIZADO');

-- ---------------------------------------------------------
-- ITENS DO CARRINHO
-- ---------------------------------------------------------
INSERT INTO item_carrinho (id_carrinho, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 1, 199.90),
(1, 5, 2, 79.90),
(2, 4, 1, 349.90),
(2, 3, 1, 149.90),
(3, 2, 1, 4599.90),
(4, 6, 1, 899.90);

-- ---------------------------------------------------------
-- PEDIDOS
-- ---------------------------------------------------------
INSERT INTO pedido (id_cliente, id_endereco_entrega, status, valor_produtos, valor_frete, valor_desconto, valor_total) VALUES
(1, 1, 'PAGO',      359.70, 20.00, 10.00, 369.70),
(2, 2, 'ENVIADO',   499.80, 25.00,  0.00, 524.80),
(3, 3, 'ENTREGUE', 4599.90, 35.00, 50.00, 4584.90),
(4, 4, 'CRIADO',    899.90, 18.00,  0.00, 917.90);

-- ---------------------------------------------------------
-- ITENS DOS PEDIDOS
-- ---------------------------------------------------------
INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario, desconto_item, subtotal) VALUES
(1, 1, 1, 199.90, 0.00, 199.90),
(1, 5, 2, 79.90, 10.00, 159.80),
(2, 4, 1, 349.90, 0.00, 349.90),
(2, 3, 1, 149.90, 0.00, 149.90),
(3, 2, 1, 4599.90, 50.00, 4549.90),
(4, 6, 1, 899.90, 0.00, 899.90);

-- ---------------------------------------------------------
-- PAGAMENTOS
-- ---------------------------------------------------------
INSERT INTO pagamento (id_pedido, forma_pagamento, status_pagamento, valor_pago, data_pagamento, codigo_transacao) VALUES
(1, 'PIX',    'APROVADO', 369.70, NOW(), 'TXN001'),
(2, 'CARTAO', 'APROVADO', 524.80, NOW(), 'TXN002'),
(3, 'BOLETO', 'APROVADO', 4584.90, NOW(), 'TXN003'),
(4, 'PIX',    'PENDENTE', 917.90, NULL,  'TXN004');

-- ---------------------------------------------------------
-- ENTREGAS
-- ---------------------------------------------------------
INSERT INTO entrega (id_pedido, transportadora, codigo_rastreio, status_entrega, data_envio, data_entrega_prevista, data_entrega_realizada) VALUES
(1, 'Correios', 'BR123456789', 'PENDENTE',    NOW(), DATE_ADD(NOW(), INTERVAL 5 DAY), NULL),
(2, 'Jadlog',   'JD987654321', 'EM_TRANSITO', NOW(), DATE_ADD(NOW(), INTERVAL 3 DAY), NULL),
(3, 'Correios', 'BR555666777', 'ENTREGUE',    NOW(), DATE_ADD(NOW(), INTERVAL 4 DAY), NOW()),
(4, 'Loggi',    'LG111222333', 'PENDENTE',    NULL,  NULL, NULL);

-- =========================================================
-- 4. CONSULTAS RAPIDAS DE VERIFICACAO
-- Essas consultas sao opcionais, mas ajudam a validar a carga
-- =========================================================

-- Ver todos os clientes
SELECT * FROM cliente;

-- Ver todos os produtos
SELECT * FROM produto;

-- Ver todos os pedidos
SELECT * FROM pedido;

-- Ver itens dos pedidos com nome do produto
SELECT 
    ip.id_item_pedido,
    ip.id_pedido,
    p.nome AS produto,
    ip.quantidade,
    ip.preco_unitario,
    ip.subtotal
FROM item_pedido ip
JOIN produto p ON p.id_produto = ip.id_produto;

-- Ver pagamentos
SELECT * FROM pagamento;

-- Ver entregas
SELECT * FROM entrega;