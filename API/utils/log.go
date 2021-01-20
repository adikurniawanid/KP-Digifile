package utils

import (
	"fmt"
	"os"
	"runtime"
	"strconv"
	"strings"
	"template-api-gecho/constant"

	"github.com/joho/godotenv"
	"github.com/sirupsen/logrus"
)

var log *logrus.Logger

func init() {
	err := godotenv.Load()
	if err != nil {
		println(err.Error())
	}

	createLogDirIfNotExist()
	initLogrus()
}

func createLogDirIfNotExist() {
	if _, err := os.Stat(getLogFilePath(constant.TypeAll)); os.IsNotExist(err) {
		logDir := os.Getenv(constant.LogDir)
		err = os.MkdirAll(logDir, 0777)
		if err != nil {
			println(err.Error())
		}
	}
}

func initLogrus() {
	log = logrus.New()
	log.Out = os.Stdout
	log.SetFormatter(&logrus.JSONFormatter{})

	setLogOutput(constant.TypeAll)
}

func getLogFilePath(logType int) string {
	switch logType {
	case constant.TypeAll:
		logDir := os.Getenv(constant.LogDir)
		logFile := os.Getenv(constant.LogFile)
		return fmt.Sprintf("%s/%s", logDir, logFile)
	case constant.TypeInfo:
		logDir := os.Getenv(constant.LogDir)
		logFile := os.Getenv(constant.LogInfo)
		return fmt.Sprintf("%s/%s", logDir, logFile)
	case constant.TypeWarn:
		logDir := os.Getenv(constant.LogDir)
		logFile := os.Getenv(constant.LogWarn)
		return fmt.Sprintf("%s/%s", logDir, logFile)
	case constant.TypeError:
		logDir := os.Getenv(constant.LogDir)
		logFile := os.Getenv(constant.LogError)
		return fmt.Sprintf("%s/%s", logDir, logFile)
	case constant.TypeFatal:
		logDir := os.Getenv(constant.LogDir)
		logFile := os.Getenv(constant.LogFatal)
		return fmt.Sprintf("%s/%s", logDir, logFile)
	case constant.TypePanic:
		logDir := os.Getenv(constant.LogDir)
		logFile := os.Getenv(constant.LogPanic)
		return fmt.Sprintf("%s/%s", logDir, logFile)
	default:
		logDir := os.Getenv(constant.LogDir)
		logFile := os.Getenv(constant.LogFile)
		return fmt.Sprintf("%s/%s", logDir, logFile)
	}
}

func setLogOutput(typeLog int) {
	logType := os.Getenv(constant.LogType)

	switch logType {
	case constant.TypeCombine:
		file, err := os.OpenFile(
			getLogFilePath(constant.TypeAll),
			os.O_CREATE|os.O_WRONLY|os.O_APPEND,
			0777,
		)

		if err != nil {
			LogPanic(err)
		}

		log.Out = file
	case constant.TypeSplit:
		file, err := os.OpenFile(
			getLogFilePath(typeLog),
			os.O_CREATE|os.O_WRONLY|os.O_APPEND,
			0777,
		)

		if err != nil {
			LogPanic(err)
		}

		log.Out = file
	}
}

// Log info into LOG_INFO or LOG_FILE
func LogInfo(message string) {
	_, file, line, ok := runtime.Caller(1)
	if !ok {
		panic(constant.ContextLogger)
	}

	filename := file[strings.LastIndex(file, "/")+1:] + ":" + strconv.Itoa(line)

	setLogOutput(constant.TypeInfo)

	log.WithFields(logrus.Fields{
		constant.KeyFile: filename,
	}).Info(message)
}

// Log warning into LOG_WARN or LOG_FILE
func LogWarn(message string) {
	_, file, line, ok := runtime.Caller(1)
	if !ok {
		panic(constant.ContextLogger)
	}

	filename := file[strings.LastIndex(file, "/")+1:] + ":" + strconv.Itoa(line)

	setLogOutput(constant.TypeWarn)

	log.WithFields(logrus.Fields{
		constant.KeyFile: filename,
	}).Warn(message)
}

// Log error into LOG_ERROR or LOG_FILE
func LogError(err error) {
	_, file, line, ok := runtime.Caller(1)
	if !ok {
		panic(constant.ContextLogger)
	}

	filename := file[strings.LastIndex(file, "/")+1:] + ":" + strconv.Itoa(line)

	setLogOutput(constant.TypeError)

	log.WithFields(logrus.Fields{
		constant.KeyFile: filename,
	}).Error(err.Error())
}

// Log fatal into LOG_FATAL or LOG_FILE
func LogFatal(err error) {
	_, file, line, ok := runtime.Caller(1)
	if !ok {
		panic(constant.ContextLogger)
	}

	filename := file[strings.LastIndex(file, "/")+1:] + ":" + strconv.Itoa(line)

	setLogOutput(constant.TypeFatal)

	log.WithFields(logrus.Fields{
		constant.KeyFile: filename,
	}).Fatal(err.Error())
}

// Log panic into LOG_PANIC or LOG_FILE
func LogPanic(err error) {
	_, file, line, ok := runtime.Caller(1)
	if !ok {
		panic(constant.ContextLogger)
	}

	filename := file[strings.LastIndex(file, "/")+1:] + ":" + strconv.Itoa(line)

	setLogOutput(constant.TypePanic)

	log.WithFields(logrus.Fields{
		constant.KeyFile: filename,
	}).Panic(err.Error())
}
