<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:def="http://www.example.org/products"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" indent="yes" />

	<xsl:param name="category"></xsl:param>

	<xsl:template match="products">
		<html>
			<head>
				<title>List of subcategories</title>
				<link rel="stylesheet" href="/task3/resources/css/styles-xsl.css"></link>				
			</head>
			<body>
				<div class="container">
					<xsl:choose>
						<xsl:when
							test="count(//category[@category_name=$category]) &gt; 0">
							<h1>
								Category:
								<xsl:value-of select="$category" />
							</h1>
							<h2>Subcategories:</h2>
							<div class="content">
							<xsl:for-each
								select="category[@category_name=$category]/subcategory">
								<p>
									<xsl:element name="a">
										<xsl:attribute name="href"><xsl:text>/task3/categories/</xsl:text><xsl:value-of
											select="$category" /><xsl:text>/</xsl:text><xsl:value-of
											select="@subcategory_name" /></xsl:attribute>
										<xsl:value-of select="@subcategory_name" />
										<xsl:text> ( </xsl:text>
										<xsl:value-of select="count(good)" />
										<xsl:text> )</xsl:text>
									</xsl:element>
								</p>
							</xsl:for-each>
							<br></br>
							<p>
							<xsl:element name="button">
								<xsl:attribute name="onClick"><xsl:text>location.href='/task3/categories'</xsl:text></xsl:attribute>	
									<xsl:text>BACK</xsl:text>							
							</xsl:element>									
							</p></div>
						</xsl:when>
						<xsl:otherwise>
							<h2>Wrong category name</h2>
							<a href="/task3/categories">Go to category list</a>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
