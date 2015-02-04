<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:def="http://www.example.org/products"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" indent="yes" />
	<xsl:template match="products">
		<html>
			<head>
				<title>List of categories</title>
				<link rel="stylesheet" type="text/css" href="/task3/resources/css/styles-xsl.css"></link>				
			</head>
			<body>
				<div class="container">
					<h1>Categories:</h1>
					<div class="content">
					<xsl:for-each select="category">
						<p>
							<xsl:element name="a">
								<xsl:attribute name="href"><xsl:text>/task3/categories/</xsl:text><xsl:value-of
									select="@category_name" /></xsl:attribute>
								<xsl:value-of select="@category_name" />
								<xsl:text> ( </xsl:text>
								<xsl:value-of select="count(subcategory)" />
								<xsl:text> )</xsl:text>
							</xsl:element>
						</p>
					</xsl:for-each></div>
				</div>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
