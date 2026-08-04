package main

import (
	"fmt"
	"os"
	"strings"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
	"github.com/xackery/goeq/item"
)

func main() {
	err := run()
	if err != nil {
		fmt.Println("run failed:", err)
		os.Exit(1)
	}
}

func run() error {
	var err error
	username := "root"
	password := "2EZM6@TRBOJN29WUO@AC41V%P_E()(I*"
	host := "127.0.0.1"
	port := "3306"
	dbName := "peq"
	db, err := sqlx.Open("mysql", fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8&parseTime=true", username, password, host, port, dbName))
	if err != nil {
		return fmt.Errorf("error connecting to db: %w", err)
	}
	defer db.Close()

	type itemTable struct {
		ID         int
		roseID     int
		apocID     int
		roseOffset int
		apocOffset int
	}

	itemMaps := map[string]*itemTable{}

	duplicateWriter, err := os.Create("duplicate.txt")
	if err != nil {
		return err
	}
	defer duplicateWriter.Close()

	start := time.Now()
	offset := 0
	var items []item.Item
	for offset == 0 || len(items) > 0 {
		items, err = getItemsByOffset(db, offset)
		if err != nil {
			return fmt.Errorf("get item by offset %d: %w", offset, err)
		}

		offset += 1000

		if len(items) < 1 {
			break
		}
		for _, item := range items {
			baseName := baseName(item.Name)
			im, ok := itemMaps[baseName]
			if !ok {
				im = &itemTable{}
				itemMaps[baseName] = im
			}

			if strings.HasPrefix(item.Name, "Rose Colored ") {
				im.roseID = item.Id
			} else if strings.HasPrefix(item.Name, "Apocryphal ") {
				im.apocID = item.Id
			} else {
				if im.ID != 0 {
					duplicateWriter.WriteString(fmt.Sprintf("%d, %d, %s\n", im.ID, item.Id, item.Name))
				}
				im.ID = item.Id
			}
		}
	}

	fmt.Println("processed", len(itemMaps), "entries in", time.Since(start).Seconds(), "seconds")
	missingWriter, err := os.Create("missing.txt")
	if err != nil {
		return err
	}
	defer missingWriter.Close()

	goodWriter, err := os.Create("good.txt")
	if err != nil {
		return err
	}
	defer goodWriter.Close()

	for name, item := range itemMaps {
		if item.ID == 0 {
			missingWriter.WriteString(fmt.Sprintf("%d, %d, %d, %s (is missing normal item id)\n", item.ID, item.roseID, item.apocID, sanitizeCSV(name)))
			continue
		}
		if item.roseID == 0 {
			missingWriter.WriteString(fmt.Sprintf("%d, %d, %d, %s (is missing rose item id)\n", item.ID, item.roseID, item.apocID, sanitizeCSV(name)))
			continue
		}
		if item.apocID == 0 {
			missingWriter.WriteString(fmt.Sprintf("%d, %d, %d, %s (is missing apoc item id)\n", item.ID, item.roseID, item.apocID, sanitizeCSV(name)))
			continue
		}
		item.roseOffset = item.roseID - item.ID
		item.apocOffset = item.apocID - item.ID
		goodWriter.WriteString(fmt.Sprintf("%d, %d, %d, %d, %d, %s\n", item.ID, item.roseID, item.apocID, item.roseOffset, item.apocOffset, sanitizeCSV(name)))
	}

	return nil
}

func getItemsByOffset(db *sqlx.DB, offset int) ([]item.Item, error) {
	if db == nil {
		return nil, fmt.Errorf("database is nil")
	}

	items := []item.Item{}
	query := "SELECT * FROM items_ret ORDER BY id LIMIT 1000 OFFSET ?"
	err := db.Select(&items, query, offset)
	if err != nil {
		return nil, err
	}
	return items, nil
}

func baseName(name string) string {
	out := strings.TrimPrefix(name, "Rose Colored ")
	out = strings.TrimPrefix(out, "Apocryphal ")
	return out
}

func sanitizeCSV(in string) string {
	in = strings.ReplaceAll(in, ",", "")
	return in
}
