import logging
import os
from voxolab import convert
from voxolab import convert_subtitle
from voxolab import seg_ctm_to_xml
from voxolab import xml_alpha_to_numbers
from voxolab import xml_to_xml_punctuated
from shutil import copyfile

logger = logging.getLogger(__name__)


def docker_decode(filename, output_dir, model, models,
                  scripts_dir):

    filename = os.path.basename(filename)
    base, ext = os.path.splitext(filename)
    decode_dir = os.path.join(output_dir, base)

    if model not in models:
        raise KeyError("model {} is not present in loaded"
                       "configuration.".format(model))

    command = models[model]['DECODE_CMD']

    full_command = command.format(
        file=filename)

    print("Hell yeah, trying to decode {} in {} with command\n{}"
          .format(filename, output_dir, full_command))

    # TODO: manage return code
    os.system(full_command)

    convert_decode_output(
        model,
        decode_dir,
        base,
        scripts_dir,
        models[model]['RECASE_DIR']
        if 'RECASE_DIR' in models[model] else None,
        models[model]['PUNCTUATE_CMD']
        if 'PUNCTUATE_CMD' in models[model] else None)

    return 0


def convert_decode_output(
        model, decode_dir, base, scripts_dir, recase_path,
        punctuate_command):

    ctm_file_min = os.path.join(decode_dir, base + ".ctm")
    ctm_file_maj = os.path.join(decode_dir, base + ".MAJ.ctm")
    seg_file = os.path.join(decode_dir, 'seg', base + ".iv.seg")
    seg_file_sorted = os.path.join(decode_dir, 'seg', base + ".iv.seg.sorted")

    xml_file_without_numbers = os.path.join(
        decode_dir, base + ".withoutnumbers.xml")

    xml_file_with_punctuation = os.path.join(
        decode_dir, base + ".withpunctuation.xml")

    xml_file = os.path.join(decode_dir, base + ".v2.xml")
    srt_file = os.path.join(decode_dir, base + ".srt")
    webvtt_file = os.path.join(decode_dir, base + ".vtt")
    txt_file = os.path.join(decode_dir, base + ".txt")
    txt_file_postprocessing = os.path.join(decode_dir, base + ".pp.txt")
    txt_file_original = os.path.join(decode_dir, base + ".original.txt")

    if('french' in model and recase_path is not None):
        convert.recase_ctm(ctm_file_min, ctm_file_maj, recase_path)
    else:
        copyfile(ctm_file_min, ctm_file_maj)

    os.system("sort -k3,3 -n {} > {}".format(seg_file, seg_file_sorted))
    seg_ctm_to_xml.seg_ctm_to_xml(
        seg_file_sorted, ctm_file_maj, xml_file_without_numbers)

    convert.xml_to_txt(xml_file_without_numbers, txt_file)

    if punctuate_command is not None:

        try:
            xml_string =\
                xml_to_xml_punctuated.punctuate_xml(
                        xml_file_without_numbers,
                        punctuate_command)
            with open(xml_file_with_punctuation, "w") as f:
                f.write(xml_string)

        except Exception as e:
            logger.exception("Error while punctuating: " + str(e))
            copyfile(xml_file_without_numbers, xml_file_with_punctuation)
    else:
        copyfile(xml_file_without_numbers, xml_file_with_punctuation)

    if 'french' in model:
        xml_alpha_to_numbers.xml_alpha_to_numbers_from_file(
            xml_file_with_punctuation,
            os.path.join(scripts_dir, 'convertirAlphaEnNombre.pl'),
            os.path.join(scripts_dir, 'convertirNombreEnAlpha.pl'),
            xml_file,
            'utf-8', 'utf-8')
    else:
        copyfile(xml_file_with_punctuation, xml_file)

    convert.xml_to_srt(xml_file, srt_file)
    convert.xml_to_webvtt(xml_file, webvtt_file)

    try:
        convert_subtitle.make_convert_subtitle(
            srt_file,
            'ScenaristClosedCaptions',
            '{mono} {se}'.format(
                mono='mono',
                se=os.path.join(scripts_dir, 'SubtitleEdit.exe')
            )
        )
    except Exception as e:
        logger.exception("Error while converting to SCC")

    if os.path.exists(os.path.join(
            scripts_dir, 'txt_post_processing_{}.pl'.format(model))):

        # Save file before post processing
        copyfile(txt_file, txt_file_original)

        os.system('perl {}/txt_post_processing_{}.pl < {} > {}'.format(
            scripts_dir, model, txt_file_postprocessing))

        copyfile(txt_file_postprocessing, txt_file)
