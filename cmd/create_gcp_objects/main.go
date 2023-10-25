package main

import (
	"bufio"
	"context"
	"errors"
	"fmt"
	"io"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"cloud.google.com/go/storage"
	"github.com/panjf2000/ants/v2"
)

type args struct {
	path string
	size uint64
}

const GoroutineLimit = 50

func init() {
	// Seed the random number generator
	rand.Seed(time.Now().UnixNano())
}

func main() {
	ctx := context.Background()

	bucketName := os.Getenv("BUCKET")
	if bucketName == "" {
		fmt.Println("Error: BUCKET env variable is not set.")
		os.Exit(1)
	}

	if len(os.Args) != 3 {
		fmt.Printf("Usage: %s <template> <prefix>\n", os.Args[0])
		os.Exit(1)
	}

	template := os.Args[1]
	prefix := strings.TrimRight(os.Args[2], "/")

	templateFile, err := os.Open(template)
	if err != nil {
		fmt.Printf("Error: Unable to open template file: %v\n", err)
		os.Exit(1)
	}
	defer templateFile.Close()

	client, err := storage.NewClient(ctx)
	if err != nil {
		fmt.Printf("Error: Unable to create a Google Cloud Storage client: %v\n", err)
		os.Exit(1)
	}

	var wg sync.WaitGroup
	errCh := make(chan error, GoroutineLimit)
	pool, _ := ants.NewPoolWithFunc(GoroutineLimit, func(i interface{}) {
		args := i.(args)
		if err := createObject(ctx, client, bucketName, args.path, args.size); err != nil {
			errCh <- err
		}
		wg.Done()
	})
	defer pool.Release()

	scanner := bufio.NewScanner(templateFile)
	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Fields(line)
		if len(parts) != 2 {
			fmt.Printf("Error: Invalid line in the template: %s\n", line)
			continue
		}

		path := fmt.Sprintf("%s/%s", prefix, parts[1])
		size, err := strconv.ParseUint(parts[0], 10, 64)
		if err != nil {
			fmt.Printf("Error: Failed to parse number in template: %v\n", err)
			continue
		}

		args := args{path, size}
		wg.Add(1)
		_ = pool.Invoke(args)
	}

	wg.Wait()
	close(errCh)
	for err := range errCh {
		if err != nil {
			fmt.Println("Failure")
			return
		}
	}
	fmt.Println("Success")
}

func createObject(ctx context.Context, client *storage.Client, bucket, path string, size uint64) error {
	obj := client.Bucket(bucket).Object(path)
	_, err := obj.Attrs(ctx)
	if errors.Is(err, storage.ErrObjectNotExist) {
		// Generate and upload random data
		w := obj.NewWriter(ctx)
		if err := writeRandomData(w, size); err != nil {
			fmt.Printf("Error: Failed to write object data: %v\n", err)
			return err
		}
		if err := w.Close(); err != nil {
			fmt.Printf("Error: Failed to close object writer: %v\n", err)
		}
		fmt.Printf("Uploaded %s with size %d bytes\n", path, size)
		return nil
	} else if err == nil {
		fmt.Printf("Object gs://%s already exists. Skipping...\n", obj.ObjectName())
		return nil
	} else {
		fmt.Printf("Error: Failed to check object existence: %v\n", err)
		return err
	}
}

func writeRandomData(w io.Writer, n uint64) error {
	data := make([]byte, n)
	_, err := rand.Read(data)
	if err != nil {
		return err
	}

	_, err = w.Write(data)
	return err
}
