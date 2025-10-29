-- Northwind Database Schema and Sample Data for Azure SQL Database

-- Create Tables
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(15) NOT NULL,
    Description NVARCHAR(MAX),
    Picture VARBINARY(MAX)
);

CREATE TABLE Customers (
    CustomerID NCHAR(5) PRIMARY KEY,
    CompanyName NVARCHAR(40) NOT NULL,
    ContactName NVARCHAR(30),
    ContactTitle NVARCHAR(30),
    Address NVARCHAR(60),
    City NVARCHAR(15),
    Region NVARCHAR(15),
    PostalCode NVARCHAR(10),
    Country NVARCHAR(15),
    Phone NVARCHAR(24),
    Fax NVARCHAR(24)
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    LastName NVARCHAR(20) NOT NULL,
    FirstName NVARCHAR(10) NOT NULL,
    Title NVARCHAR(30),
    TitleOfCourtesy NVARCHAR(25),
    BirthDate DATETIME,
    HireDate DATETIME,
    Address NVARCHAR(60),
    City NVARCHAR(15),
    Region NVARCHAR(15),
    PostalCode NVARCHAR(10),
    Country NVARCHAR(15),
    HomePhone NVARCHAR(24),
    Extension NVARCHAR(4),
    Notes NVARCHAR(MAX),
    ReportsTo INT,
    PhotoPath NVARCHAR(255)
);

CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    CompanyName NVARCHAR(40) NOT NULL,
    ContactName NVARCHAR(30),
    ContactTitle NVARCHAR(30),
    Address NVARCHAR(60),
    City NVARCHAR(15),
    Region NVARCHAR(15),
    PostalCode NVARCHAR(10),
    Country NVARCHAR(15),
    Phone NVARCHAR(24),
    Fax NVARCHAR(24),
    HomePage NVARCHAR(MAX)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(40) NOT NULL,
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit NVARCHAR(20),
    UnitPrice MONEY,
    UnitsInStock SMALLINT,
    UnitsOnOrder SMALLINT,
    ReorderLevel SMALLINT,
    Discontinued BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

CREATE TABLE Shippers (
    ShipperID INT PRIMARY KEY IDENTITY(1,1),
    CompanyName NVARCHAR(40) NOT NULL,
    Phone NVARCHAR(24)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID NCHAR(5),
    EmployeeID INT,
    OrderDate DATETIME,
    RequiredDate DATETIME,
    ShippedDate DATETIME,
    ShipVia INT,
    Freight MONEY,
    ShipName NVARCHAR(40),
    ShipAddress NVARCHAR(60),
    ShipCity NVARCHAR(15),
    ShipRegion NVARCHAR(15),
    ShipPostalCode NVARCHAR(10),
    ShipCountry NVARCHAR(15),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ShipVia) REFERENCES Shippers(ShipperID)
);

CREATE TABLE [Order Details] (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    UnitPrice MONEY NOT NULL,
    Quantity SMALLINT NOT NULL,
    Discount REAL NOT NULL,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Insert Sample Data
SET IDENTITY_INSERT Categories ON;
INSERT INTO Categories (CategoryID, CategoryName, Description) VALUES
(1, 'Beverages', 'Soft drinks, coffees, teas, beers, and ales'),
(2, 'Condiments', 'Sweet and savory sauces, relishes, spreads, and seasonings'),
(3, 'Confections', 'Desserts, candies, and sweet breads'),
(4, 'Dairy Products', 'Cheeses'),
(5, 'Grains/Cereals', 'Breads, crackers, pasta, and cereal'),
(6, 'Meat/Poultry', 'Prepared meats'),
(7, 'Produce', 'Dried fruit and bean curd'),
(8, 'Seafood', 'Seaweed and fish');
SET IDENTITY_INSERT Categories OFF;

INSERT INTO Customers (CustomerID, CompanyName, ContactName, ContactTitle, City, Country) VALUES
('ALFKI', 'Alfreds Futterkiste', 'Maria Anders', 'Sales Representative', 'Berlin', 'Germany'),
('ANATR', 'Ana Trujillo Emparedados y helados', 'Ana Trujillo', 'Owner', 'México D.F.', 'Mexico'),
('ANTON', 'Antonio Moreno Taquería', 'Antonio Moreno', 'Owner', 'México D.F.', 'Mexico'),
('AROUT', 'Around the Horn', 'Thomas Hardy', 'Sales Representative', 'London', 'UK'),
('BERGS', 'Berglunds snabbköp', 'Christina Berglund', 'Order Administrator', 'Luleå', 'Sweden'),
('BLAUS', 'Blauer See Delikatessen', 'Hanna Moos', 'Sales Representative', 'Mannheim', 'Germany'),
('BLONP', 'Blondesddsl père et fils', 'Frédérique Citeaux', 'Marketing Manager', 'Strasbourg', 'France'),
('BOLID', 'Bólido Comidas preparadas', 'Martín Sommer', 'Owner', 'Madrid', 'Spain'),
('BONAP', 'Bon app''', 'Laurence Lebihan', 'Owner', 'Marseille', 'France'),
('BOTTM', 'Bottom-Dollar Markets', 'Elizabeth Lincoln', 'Accounting Manager', 'Tsawassen', 'Canada');

SET IDENTITY_INSERT Employees ON;
INSERT INTO Employees (EmployeeID, LastName, FirstName, Title, BirthDate, HireDate, City, Country) VALUES
(1, 'Davolio', 'Nancy', 'Sales Representative', '1948-12-08', '1992-05-01', 'Seattle', 'USA'),
(2, 'Fuller', 'Andrew', 'Vice President, Sales', '1952-02-19', '1992-08-14', 'Tacoma', 'USA'),
(3, 'Leverling', 'Janet', 'Sales Representative', '1963-08-30', '1992-04-01', 'Kirkland', 'USA'),
(4, 'Peacock', 'Margaret', 'Sales Representative', '1937-09-19', '1993-05-03', 'Redmond', 'USA'),
(5, 'Buchanan', 'Steven', 'Sales Manager', '1955-03-04', '1993-10-17', 'London', 'UK'),
(6, 'Suyama', 'Michael', 'Sales Representative', '1963-07-02', '1993-10-17', 'London', 'UK'),
(7, 'King', 'Robert', 'Sales Representative', '1960-05-29', '1994-01-02', 'London', 'UK'),
(8, 'Callahan', 'Laura', 'Inside Sales Coordinator', '1958-01-09', '1994-03-05', 'Seattle', 'USA'),
(9, 'Dodsworth', 'Anne', 'Sales Representative', '1966-01-27', '1994-11-15', 'London', 'UK');
SET IDENTITY_INSERT Employees OFF;

SET IDENTITY_INSERT Suppliers ON;
INSERT INTO Suppliers (SupplierID, CompanyName, ContactName, City, Country, Phone) VALUES
(1, 'Exotic Liquids', 'Charlotte Cooper', 'London', 'UK', '(171) 555-2222'),
(2, 'New Orleans Cajun Delights', 'Shelley Burke', 'New Orleans', 'USA', '(100) 555-4822'),
(3, 'Grandma Kelly''s Homestead', 'Regina Murphy', 'Ann Arbor', 'USA', '(313) 555-5735'),
(4, 'Tokyo Traders', 'Yoshi Nagase', 'Tokyo', 'Japan', '(03) 3555-5011'),
(5, 'Cooperativa de Quesos', 'Antonio del Valle Saavedra', 'Oviedo', 'Spain', '(98) 598 76 54');
SET IDENTITY_INSERT Suppliers OFF;

SET IDENTITY_INSERT Products ON;
INSERT INTO Products (ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued) VALUES
(1, 'Chai', 1, 1, '10 boxes x 20 bags', 18.00, 39, 0, 10, 0),
(2, 'Chang', 1, 1, '24 - 12 oz bottles', 19.00, 17, 40, 25, 0),
(3, 'Aniseed Syrup', 1, 2, '12 - 550 ml bottles', 10.00, 13, 70, 25, 0),
(4, 'Chef Anton''s Cajun Seasoning', 2, 2, '48 - 6 oz jars', 22.00, 53, 0, 0, 0),
(5, 'Chef Anton''s Gumbo Mix', 2, 2, '36 boxes', 21.35, 0, 0, 0, 1),
(6, 'Grandma''s Boysenberry Spread', 3, 2, '12 - 8 oz jars', 25.00, 120, 0, 25, 0),
(7, 'Uncle Bob''s Organic Dried Pears', 3, 7, '12 - 1 lb pkgs.', 30.00, 15, 0, 10, 0),
(8, 'Northwoods Cranberry Sauce', 3, 2, '12 - 12 oz jars', 40.00, 6, 0, 0, 0),
(9, 'Mishi Kobe Niku', 4, 6, '18 - 500 g pkgs.', 97.00, 29, 0, 0, 1),
(10, 'Ikura', 4, 8, '12 - 200 ml jars', 31.00, 31, 0, 0, 0);
SET IDENTITY_INSERT Products OFF;

SET IDENTITY_INSERT Shippers ON;
INSERT INTO Shippers (ShipperID, CompanyName, Phone) VALUES
(1, 'Speedy Express', '(503) 555-9831'),
(2, 'United Package', '(503) 555-3199'),
(3, 'Federal Shipping', '(503) 555-9931');
SET IDENTITY_INSERT Shippers OFF;

SET IDENTITY_INSERT Orders ON;
INSERT INTO Orders (OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipCity, ShipCountry) VALUES
(10248, 'ALFKI', 5, '1996-07-04', '1996-08-01', '1996-07-16', 3, 32.38, 'Reims', 'France'),
(10249, 'ANATR', 6, '1996-07-05', '1996-08-16', '1996-07-10', 1, 11.61, 'Münster', 'Germany'),
(10250, 'ANTON', 4, '1996-07-08', '1996-08-05', '1996-07-12', 2, 65.83, 'Rio de Janeiro', 'Brazil'),
(10251, 'AROUT', 3, '1996-07-08', '1996-08-05', '1996-07-15', 1, 41.34, 'Lyon', 'France'),
(10252, 'BERGS', 4, '1996-07-09', '1996-08-06', '1996-07-11', 2, 51.30, 'Charleroi', 'Belgium');
SET IDENTITY_INSERT Orders OFF;

INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount) VALUES
(10248, 1, 14.00, 12, 0),
(10248, 2, 9.80, 10, 0),
(10248, 3, 10.00, 5, 0),
(10249, 1, 14.00, 9, 0),
(10249, 2, 9.80, 40, 0),
(10250, 4, 22.00, 10, 0),
(10250, 5, 21.35, 35, 0.15),
(10251, 1, 14.00, 6, 0.05),
(10251, 7, 30.00, 15, 0.05),
(10252, 8, 40.00, 40, 0.05);

GO
