# setup_logging.py

import logging
import logging.config


class CustomFormatter(logging.Formatter):
    """Logging Formatter to ad colors and count warnings / errors"""

    pink = "\x1b[35m"
    blue = "\033[96m"
    yellow = "\033[93m"
    red = "\x1b[31;21m"
    bold_red = "\033[41m"
    reset = "\x1b[0m"
    format = "%(asctime)s | %(name)s | %(levelname)s | %(message)s"

    FORMATS = {
        logging.DEBUG: pink + format + reset,
        logging.INFO: blue + format + reset,
        logging.WARNING: yellow + format + reset,
        logging.ERROR: red + format + reset,
        logging.CRITICAL: bold_red + format + reset
    }

    def format(self, record: logging.LogRecord) -> str:
        log_format = self.FORMATS.get(record.levelno)
        formatter = logging.Formatter(log_format)
        return formatter.format(record)


def setup_logger(logger: logging.Logger, log_file_path: str) -> None:
    """
    function that setups a standard logger
    :rtype: None
    :param logger: logger object initiated at the beginning of the file
    :param log_file_path: path and name of log file
    :return:  None only modifications are made to the logger object
    """

    logger.setLevel(logging.DEBUG)

    # create handlers
    console_handler = logging.StreamHandler()
    file_handler = logging.FileHandler(log_file_path)

    # set levels of the handlers
    console_handler.setLevel(level=logging.DEBUG)
    file_handler.setLevel(level=logging.INFO)

    # create formats and set them to the handlers
    file_format = logging.Formatter('%(asctime)s | %(name)s | %(levelname)s | %(message)s')

    console_handler.setFormatter(CustomFormatter())
    file_handler.setFormatter(file_format)

    # add handlers to the logger
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
