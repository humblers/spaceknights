package data

import (
	"encoding/csv"
	"fmt"
	"os"
)

func addNewColumn(name string, idx int, c *map[string]int) bool {
	m := *c
	if m[name] > 0 {
		return false
	}
	m[name] = idx
	return true
}
func main() {
	Initialize()

	columns := make(map[string]int)
	records := [][]string{
		{"name"},
	}

	// collect columns
	for _, u := range Units {
		for k, _ := range u {
			switch k {
			case "targettypes":
				if added := addNewColumn(k, len(records[0]), &columns); added {
					records[0] = append(records[0], []string{"targettype1", "targettype2", "targettype3"}...)
				}
			case "targetlayers":
				if added := addNewColumn(k, len(records[0]), &columns); added {
					records[0] = append(records[0], []string{"targetlayer1", "targetlayer2", "targettlayer3"}...)
				}
			case "hp", "shield", "attackdamage", "destroydamage", "chargedattackdamage", "powerattackdamage", "damage", "hpratio", "attackdamageratio", "attackrangeratio", "slowduration", "expanddamageradius":
				if added := addNewColumn(k, len(records[0]), &columns); added {
					for i := 0; i < LevelMax; i++ {
						records[0] = append(records[0], fmt.Sprintf("%v%d", k, i+1))
					}
				}
			default:
				if added := addNewColumn(k, len(records[0]), &columns); added {
					records[0] = append(records[0], k)
				}
			}
		}
	}

	// fill unit data by column order
	for name, u := range Units {
		record := make([]string, len(records[0]), len(records[0]))
		record[0] = name
		for k, v := range u {
			switch k {
			case "targettypes":
				idx := columns[k]
				for i, val := range v.(UnitTypes) {
					record[idx+i] = fmt.Sprintf("%v", val)
				}
			case "targetlayers":
				idx := columns[k]
				for i, val := range v.(UnitLayers) {
					record[idx+i] = fmt.Sprintf("%v", val)
				}
			case "hp", "shield", "attackdamage", "destroydamage", "chargedattackdamage", "powerattackdamage", "damage", "hpratio", "attackdamageratio", "attackrangeratio", "slowduration", "expanddamageradius":
				idx := columns[k]
				if _, ok := v.([]int); !ok {
					fmt.Printf("value's type is not []int k:%v, v:%v\n", k, v)
					continue
				}
				for i, val := range v.([]int) {
					record[idx+i] = fmt.Sprintf("%v", val)
				}
			default:
				record[columns[k]] = fmt.Sprintf("%v", v)
			}
		}
		records = append(records, record)
	}

	// open csv file
	f, err := os.Create("unit.csv")
	if err != nil {
		panic(err)
	}
	defer f.Close()
	defer f.Sync()

	w := csv.NewWriter(f)
	w.WriteAll(records)
	defer w.Flush()

	if err := w.Error(); err != nil {
		t.Errorf("export err: %v", err)
	}
}
