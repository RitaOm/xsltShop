<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:def="http://www.example.org/products"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" indent="yes" />

	<xsl:param name="category"></xsl:param>
	<xsl:param name="subcategory"></xsl:param>

	<xsl:template match="products">
		<html>
			<head>
				<title>List of goods</title>
				<link rel="stylesheet" href="/task3/resources/css/styles-xsl.css"></link>			
			</head>
			<body>
				<div class="container">
					<xsl:choose>
						<xsl:when
							test="count(//category[@category_name=$category]/subcategory[@subcategory_name=$subcategory]) &gt; 0">
							<h1>
								Category:
								<xsl:value-of select="$category" />
							</h1>
							<h2>
								Subcategory:
								<xsl:value-of select="$subcategory" />
							</h2>
							<h3>Goods: </h3>
							<table class="goodsList-table content">
								<tr>
									<th>Producer</th>
									<th>Model</th>
									<th>Date</th>
									<th>Color</th>
									<th>Price,$</th>
								</tr>
								<xsl:for-each
									select="category[@category_name=$category]/subcategory[@subcategory_name=$subcategory]/good">
									<tr>
										<td>
											<xsl:value-of select="model" />
										</td>
										<td>
											<xsl:value-of select="producer" />
										</td>
										<td>
											<xsl:value-of select="date" />
										</td>
										<td>
											<xsl:value-of select="color" />
										</td>
										<td>
											<xsl:choose>
												<xsl:when test="count(.//not_in_stock) = 0">
													<xsl:value-of select="price" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:text>Not in stock</xsl:text>
												</xsl:otherwise>
											</xsl:choose>
										</td>
									</tr>
								</xsl:for-each>
							</table>							
							<div class="buttons-inline">
								<xsl:element name="button">
									<xsl:attribute name="onClick"><xsl:text>location.href='/task3/categories/</xsl:text><xsl:value-of
										select="$category" /><xsl:text>'</xsl:text></xsl:attribute>
									<xsl:text>BACK</xsl:text>
								</xsl:element>
							</div>
							<div class="buttons-inline">
								<form action="/task3/addGood" method="post">
									<input type="hidden" name="category" value="{$category}" />
									<input type="hidden" name="subcategory" value="{$subcategory}" />
									<input type="submit" value="ADD" />
								</form>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<h2>Wrong category or subcategory name</h2>
							<a href="/task3/categories">Go to category list</a>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
