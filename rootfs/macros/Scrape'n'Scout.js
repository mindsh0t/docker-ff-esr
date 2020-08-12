for (csvLine = 1 ; csvLine <= 999999 ; csvLine++)
{
	iimSet ("-var_CSVLINE", csvLine);
	iimPlay("Scrape'n'Scout.iim");
}
